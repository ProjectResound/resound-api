require 'spec_helper'
require 'duration_parser'

describe DurationParser do
  describe 'to_seconds()' do
    it 'converts a HH:MM:SS string to number of seconds' do
      expect(DurationParser.to_seconds('00:00:46.15')).to eq(46.15)
    end
  end

  describe 'to_hhmmss()' do
    it 'converts a decimal to a HH:MM:SS string' do
      expect(DurationParser.to_hhmmss(46.14)).to eq('00:00:46')
    end
    it 'returns nothing when no decimal is passed in' do
      expect(DurationParser.to_hhmmss(nil)).to be_nil
    end
  end
end
