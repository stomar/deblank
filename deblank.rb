#!/usr/bin/ruby -w
# encoding: UTF-8
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
# Copyright (C) 2012 Marcus Stollsteimer
#
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

require 'optparse'

# This module contains the classes for the +deblank+ tool.
module Deblank

  PROGNAME  = 'deblank'
  VERSION   = '0.0.1'
  DATE      = '2012-12-01'
  HOMEPAGE  = 'https://github.com/stomar/deblank'

  COPYRIGHT = "Copyright (C) 2012 Marcus Stollsteimer.\n" +
              "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n" +
              "This is free software: you are free to change and redistribute it.\n" +
              "There is NO WARRANTY, to the extent permitted by law."

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
        :files  => nil,
        :simulate => false,
      }

      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{PROGNAME} [options] file[s]"
        opt.separator ''
        opt.separator 'deblank renames files and replaces or removes special characters'
        opt.separator 'like spaces, parentheses, or umlauts.'
        opt.separator 'The new filename will only contain the following characters:'
        opt.separator ''
        opt.separator '    ' << NameConverter::VALID_CHARS
        opt.separator ''
        opt.separator 'Spaces are replaced by underscores, German umlauts and eszett are'
        opt.separator 'transliterated, all other invalid characters are removed.'
        opt.separator ''
        opt.separator 'Options'
        opt.separator ''

        # process --version and --help first,
        # exit successfully (GNU Coding Standards)
        opt.on_tail('-h', '--help', 'Print a brief help message and exit.') do
          puts opt_parser
          puts "\nReport bugs on the #{PROGNAME} home page: <#{HOMEPAGE}>"
          exit
        end

        opt.on_tail('-v', '--version',
                    'Print a brief version information and exit.') do
          puts "#{PROGNAME} #{VERSION}"
          puts COPYRIGHT
          exit
        end

        opt.on('-l', '--list',
               'List the used character substitutions.') do
          puts NameConverter.substitutions_to_string
          exit
        end

        opt.on('-n', '--no-act',
               'Do not rename files, only display what would happen.') do
          options[:simulate] = true
        end

        opt.separator ''
      end
      opt_parser.parse!(argv)

      # only file[s] should be left (at least 1 argument)
      raise(ArgumentError, 'wrong number of arguments')  if argv.size < 1

      options[:files] = Array.new(argv).map do |filename|
        correct_encoding(filename).encode('UTF-8')
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

      string.dup.force_encoding('Windows-1252')
    end
  end

  # This module provides a converter method for filenames
  # (only the base name is modified).
  module NameConverter

    VALID_CHARS = 'A-Z a-z 0-9 . _ -'  # spaces are ignored, `-' must be last

    SUBSTITUTIONS = {
      ' ' => '_',
      'ä' => 'ae',
      'ö' => 'oe',
      'ü' => 'ue',
      'Ä' => 'Ae',
      'Ö' => 'Oe',
      'Ü' => 'Ue',
      'ß' => 'ss'
    }

    def self.convert(filename)
      invalid_chars = /[^#{VALID_CHARS.tr(' ', '')}]/
      basename = File.basename(filename)
      dir = File.dirname(filename)

      SUBSTITUTIONS.each do |from, to|
        basename.gsub!(/#{from}/, to)
      end
      basename.gsub!(invalid_chars, '')

      dir == '.' ? basename : "#{dir}/#{basename}"
    end

    def self.substitutions_to_string
      output = ''
      SUBSTITUTIONS.each do |from, to|
        output << "#{from} => #{to}\n"
      end

      output
    end
  end

  # The main program. It's run! method is called
  # if the script is run from the command line.
  # It parses the command line arguments and renames the files.
  class Application

    ERRORCODE = {:general => 1, :usage => 2}

    def initialize
      begin
        options = Optionparser.parse!(ARGV)
        @files = options[:files]
        @simulate = options[:simulate]
      rescue => e
        usage_fail(e.message)
      end
    end

    # The main program.
    def run!
      message = "This is a dry run, files will not be renamed."
      warn "#{message}\n#{'-' * message.size}\n"  if @simulate

      @files.each do |filename|
        unless File.exist?(filename)
          warn "There is no file `#{filename}'. (Skipped.)"
          next
        end

        new_filename = NameConverter.convert(filename)

        # filenames are identical
        if new_filename == filename
          warn("`#{filename}' and `#{new_filename}' are the same file. (Skipped.)")
          next
        end

        # move file
        if File.exist?(new_filename)
          overwrite_ok = ask("File `#{new_filename}' already exists. Overwrite?")
          next  unless overwrite_ok
        end

        warn "Moving from `#{filename}' to `#{new_filename}'."
        File.rename(filename, new_filename)  unless @simulate
      end   # of each
    end

    # Asks for yes or no (y/n).
    #
    # +question+ - string to be printed
    #
    # Returns +true+ if the answer is yes.
    def ask(question) # :nodoc:
      loop do
        $stderr.print "#{question} [y/n] "
        reply = $stdin.gets.chomp.downcase  # $stdin: avoids gets / ARGV problem
        return true   if reply == 'y'
        return false  if reply == 'n'
        warn "Please answer `y' or `n'."
      end
    end

    # Prints an error message and a short help information, then exits.
    def usage_fail(message) # :nodoc:
      warn "#{PROGNAME}: #{message}"
      warn "Use `#{PROGNAME} --help' for valid options."
      exit ERRORCODE[:usage]
    end
  end

### call main method only if called on command line

if __FILE__ == $0
  Application.new.run!
end

end  # module