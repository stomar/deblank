#!/usr/bin/ruby -w
# encoding: UTF-8
#
# test_nameconverter.rb: Unit tests for the deblank script.
#
# Copyright (C) 2012 Marcus Stollsteimer

require 'minitest/spec'
require 'minitest/autorun'
require 'deblank'


describe Deblank::NameConverter do

  before do
    @nc = Deblank::NameConverter
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
end
