# frozen_string_literal: true

require "minitest/autorun"
require "deblank"


describe Deblank::Optionparser do

  before do
    @parser = Deblank::Optionparser
    @arg = "test_ä.txt"
    @arg_win1252_labeled_as_cp850 = (+"test_\xE4.txt").force_encoding("CP850")
    @arg_win1252 = (+"test_\xE4.txt").force_encoding("Windows-1252")
  end

  it "can correct encoding from (seemingly) CP850 to Windows-1252" do
    arg = @arg_win1252_labeled_as_cp850
    _(arg.encoding).must_equal Encoding::CP850
    corrected_arg = @parser.correct_encoding(arg)
    _(corrected_arg.encoding).must_equal Encoding::Windows_1252
  end

  it "encodes (seemingly) CP850 encoded filenames into UTF-8" do
    options = @parser.parse!([@arg_win1252_labeled_as_cp850])
    filename = options[:files].first
    _(filename.encoding).must_equal Encoding::UTF_8
    _(filename).must_equal @arg
  end

  it "encodes Windows-1252 encoded filenames into UTF-8" do
    options = @parser.parse!([@arg_win1252])
    filename = options[:files].first
    _(filename.encoding).must_equal Encoding::UTF_8
    _(filename).must_equal @arg
  end

  it "encodes UTF-8 encoded filenames into UTF-8" do
    options = @parser.parse!([@arg])
    filename = options[:files].first
    _(filename.encoding).must_equal Encoding::UTF_8
    _(filename).must_equal @arg
  end
end
