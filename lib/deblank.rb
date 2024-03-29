#!/usr/bin/env ruby
# frozen_string_literal: true

# == Name
#
# deblank - remove special characters from filenames
#
# == Description
#
# +deblank+ renames files and replaces or removes special characters
# like spaces, parentheses, or umlauts.
#
# == See also
#
# Use <tt>deblank --help</tt> to display a brief help message.
#
# == Author
#
# Copyright (C) 2012-2024 Marcus Stollsteimer
#
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

require "optparse"

# This module contains the classes for the +deblank+ tool.
module Deblank

  PROGNAME  = "deblank"
  VERSION   = "0.2.0"
  DATE      = "2024-01-05"
  HOMEPAGE  = "https://github.com/stomar/deblank"
  TAGLINE   = "remove special characters from filenames"

  COPYRIGHT = <<~TEXT
    Copyright (C) 2012-2024 Marcus Stollsteimer.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
  TEXT

  # Parser for the command line options.
  # The class method parse! does the job.
  class Optionparser

    # Parses the command line options from +argv+.
    # (+argv+ is cleared).
    # Might print out help or version information.
    #
    # +argv+ - array with the command line options
    #
    # Returns a hash containing the option parameters.
    def self.parse!(argv)
      options = {
        files: nil,
        simulate: false
      }

      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{PROGNAME} [options] file[s]"
        opt.separator ""
        opt.separator <<~DESCRIPTION
          deblank renames files and replaces or removes special characters
          like spaces, parentheses, or umlauts.
          The new filename will only contain the following characters:

              #{NameConverter.default_valid_chars_to_s}

          Spaces are replaced by underscores, German umlauts and eszett are
          transliterated, all other invalid characters are removed.

          Options:
        DESCRIPTION

        # process --version and --help first,
        # exit successfully (GNU Coding Standards)
        opt.on_tail("-h", "--help", "Print a brief help message and exit.") do
          puts opt_parser
          puts "\nReport bugs on the #{PROGNAME} home page: <#{HOMEPAGE}>"
          exit
        end

        opt.on_tail("-v", "--version",
                    "Print a brief version information and exit.") do
          puts "#{PROGNAME} #{VERSION}"
          puts COPYRIGHT
          exit
        end

        opt.on("-l", "--list",
               "List the used character substitutions.") do
          puts NameConverter.default_substitutions_to_s
          exit
        end

        opt.on("-n", "--no-act",
               "Do not rename files, only display what would happen.") do
          options[:simulate] = true
        end

        opt.separator ""
      end
      opt_parser.parse!(argv)

      # only file[s] should be left (at least 1 argument)
      raise(ArgumentError, "wrong number of arguments")  if argv.empty?

      options[:files] = Array.new(argv).map do |filename|
        correct_encoding(filename).encode("UTF-8")
      end
      argv.clear

      options
    end

    # Corrects the encoding for (seemingly) CP850 encoded strings
    # from `CP850' to `Windows-1252'.
    #
    # Returns a copy of +string+ with corrected encoding or +string+.
    #
    # [On the Windows test machine (which uses code page 850 for the
    # command prompt) the command line arguments are interpreted by Ruby
    # as CP850 encoded strings but actually are Windows-1252 encoded.]
    def self.correct_encoding(string)
      return string  unless string.encoding == Encoding::CP850

      string.dup.force_encoding("Windows-1252")
    end
  end

  # This class provides a converter method for filenames
  # (only the base name is modified).
  class NameConverter

    VALID_CHARS = "A-Za-z0-9._-"  # `-' must be last

    SUBSTITUTIONS = {
      " " => "_",
      "ä" => "ae",
      "ö" => "oe",
      "ü" => "ue",
      "Ä" => "Ae",
      "Ö" => "Oe",
      "Ü" => "Ue",
      "ß" => "ss"
    }.freeze

    def initialize
      @valid_characters = VALID_CHARS
      @substitutions = SUBSTITUTIONS
    end

    def convert(filename)
      dir, basename = File.dirname(filename), File.basename(filename)

      @substitutions.each {|from, to| basename.gsub!(/#{from}/, to) }
      basename.gsub!(invalid_characters, "")

      dir == "." ? basename : "#{dir}/#{basename}"
    end

    def invalid?(filename)
      filename.match?(invalid_characters)
    end

    def self.default_valid_chars_to_s
      VALID_CHARS.scan(/.-.|./).join(" ")
    end

    def self.default_substitutions_to_s
      SUBSTITUTIONS.map {|from, to| "#{from} => #{to}\n" }.join
    end

    private

    def invalid_characters
      /[^#{@valid_characters}]/
    end
  end

  # The main program. It's run! method is called
  # if the script is run from the command line.
  # It parses the command line arguments and renames the files.
  class Application

    ERRORCODE = { general: 1, usage: 2 }.freeze

    def initialize
      begin
        options = Optionparser.parse!(ARGV)
      rescue StandardError => e
        usage_fail(e.message)
      end
      @files = options[:files]
      @simulate = options[:simulate]
      @converter = NameConverter.new
    end

    # The main program.
    def run!
      message = "This is a dry run, files will not be renamed."
      warn "#{message}\n#{'-' * message.size}\n"  if @simulate

      @files.each do |filename|
        next  unless file_exist?(filename)
        next  unless invalid?(filename)

        new_filename = @converter.convert(filename)
        secure_rename(filename, new_filename)
      end
    end

    private

    def skip_warn(message)
      warn "#{message} (Skipped.)"
    end

    def file_exist?(filename)
      fail_message = "There is no file `#{filename}'."

      File.exist?(filename) or skip_warn(fail_message)
    end

    def invalid?(filename)
      fail_message = "`#{filename}' already is a valid filename."

      @converter.invalid?(filename) or skip_warn(fail_message)
    end

    def secure_rename(old_filename, new_filename)
      return  if File.exist?(new_filename) && !overwrite?(new_filename)

      warn "Moving from `#{old_filename}' to `#{new_filename}'."
      File.rename(old_filename, new_filename)  unless @simulate
    end

    def overwrite?(filename)
      confirm("File `#{filename}' already exists. Overwrite?")
    end

    # Asks for yes or no (y/n).
    #
    # +question+ - string to be printed
    #
    # Returns +true+ if the answer is yes.
    def confirm(question)
      loop do
        $stderr.print "#{question} [y/n] "
        reply = $stdin.gets.chomp.downcase  # $stdin avoids gets/ARGV problem
        return reply == "y"  if reply.match?(/\A[yn]\z/)

        warn "Please answer `y' or `n'."
      end
    end

    # Prints an error message and a short help information, then exits.
    def usage_fail(message)
      warn "#{PROGNAME}: #{message}"
      warn "Use `#{PROGNAME} --help' for valid options."
      exit ERRORCODE[:usage]
    end
  end
end

### call main method only if called on command line

Deblank::Application.new.run!  if __FILE__ == $PROGRAM_NAME
