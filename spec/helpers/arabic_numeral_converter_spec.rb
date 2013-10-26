#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe ArabicNumeralConverter, 'is_i?' do
  it "should be true if integer" do
    helper.is_i?("2012").should be_true
  end

  it "should be false if decimal" do
    helper.is_i?("98.7").should be_false
  end

  it "should be false if it containers letters" do
    helper.is_i?("obama").should be_false
  end
end

describe ArabicNumeralConverter, 'convert' do
  it { helper.convert("١٢٣٤٥").should eq "12345" }
  it { helper.convert("٠٩٨٧٦").should eq "09876" }
end
