# encoding: UTF-8
#
# test_optionparser.rb: Unit tests for the deblank script.
#
# Copyright (C) 2012-2014 Marcus Stollsteimer

require 'minitest/spec'
require 'minitest/autorun'
require 'deblank'


describe Deblank::Optionparser do

  before do
    @parser = Deblank::Optionparser
    @arg = "test_ä.txt"
    @arg_Win_1252_labeled_as_CP850 = "test_\xE4.txt".force_encoding('CP850')
    @arg_Win_1252 = "test_\xE4.txt".force_encoding('Windows-1252')
  end

  it 'can correct encoding from (seemingly) CP850 to Windows-1252' do
    arg = @arg_Win_1252_labeled_as_CP850
    arg.encoding.must_equal Encoding::CP850
    corrected_arg = @parser.correct_encoding(arg)
    corrected_arg.encoding.must_equal Encoding::Windows_1252
  end

  it 'encodes (seemingly) CP850 encoded filenames into UTF-8' do
    options = @parser.parse!([@arg_Win_1252_labeled_as_CP850])
    filename = options[:files].first
    filename.encoding.must_equal Encoding::UTF_8
    filename.must_equal @arg
  end

  it 'encodes Windows-1252 encoded filenames into UTF-8' do
    options = @parser.parse!([@arg_Win_1252])
    filename = options[:files].first
    filename.encoding.must_equal Encoding::UTF_8
    filename.must_equal @arg
  end

  it 'encodes UTF-8 encoded filenames into UTF-8' do
    options = @parser.parse!([@arg])
    filename = options[:files].first
    filename.encoding.must_equal Encoding::UTF_8
    filename.must_equal @arg
  end
end
