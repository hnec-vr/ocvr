#!/bin/env ruby
# encoding: utf-8٠

module ArabicNumeralConverter
  def is_i?(arabic_numeral)
    !!(arabic_numeral =~ /^[-+]?[0-9]+$/)
  end

  def convert(arabic_numeral)
    arabic_numeral.tr("١٢٣٤٥٦٧٨٩٠", "1234567890")
  end
end
