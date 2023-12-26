require "./lib/deblank"

version  = Deblank::VERSION
date     = Deblank::DATE
homepage = Deblank::HOMEPAGE
tagline  = Deblank::TAGLINE

Gem::Specification.new do |s|
  s.name              = "deblank"
  s.version           = version
  s.date              = date

  s.description = "deblank is a command line tool that " +
                  "renames files and replaces or removes special characters " +
                  "like spaces, parentheses, or umlauts."
  s.summary = "deblank - #{tagline}"

  s.authors = ["Marcus Stollsteimer"]
  s.email = "sto.mar@web.de"
  s.homepage = homepage

  s.license = "GPL-3.0"

  s.required_ruby_version = ">=1.9.2"

  s.executables = ["deblank"]
  s.bindir = "bin"

  s.require_paths = ["lib"]

  s.test_files = Dir.glob("test/**/test_*.rb")

  s.files =
    %w{
      README.md
      Rakefile
      Gemfile
      deblank.gemspec
      deblank.h2m
    } +
    Dir.glob("{bin,lib,man,test}/**/*")

  s.rdoc_options = ["--charset=UTF-8"]
end
