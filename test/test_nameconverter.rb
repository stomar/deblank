# encoding: UTF-8
#
# test_nameconverter.rb: Unit tests for the deblank script.
#
# Copyright (C) 2012-2014 Marcus Stollsteimer

require 'minitest/autorun'
require 'deblank'


describe Deblank::NameConverter do

  before do
    @nc = Deblank::NameConverter.new
  end

  it 'recognizes invalid filenames' do
    @nc.invalid?('path/to/filename with spaces.txt').must_equal true
    @nc.invalid?('filename_with_ä.txt').must_equal true
    @nc.invalid?('Valid_filename-1.txt').must_equal false
  end

  it 'does not change the path name' do
    @nc.convert('path with spaces/file.txt').must_equal 'path with spaces/file.txt'
  end

  it 'replaces spaces by underscores' do
    @nc.convert('file with spaces.txt').must_equal 'file_with_spaces.txt'
  end

  it 'removes parentheses' do
    @nc.convert('file_(another).txt').must_equal 'file_another.txt'
  end

  it 'transliterates umlauts and eszett' do
    @nc.convert('Ä_Ö_Ü_ä_ö_ü_ß.txt').must_equal 'Ae_Oe_Ue_ae_oe_ue_ss.txt'
  end

  it 'can return the default valid characters as string' do
    Deblank::NameConverter.default_valid_chars_to_s.must_equal 'A-Z a-z 0-9 . _ -'
  end

  it 'can return the default substitutions as string' do
    Deblank::NameConverter.default_substitutions_to_s.split("\n")[0].must_equal '  => _'
  end
end
