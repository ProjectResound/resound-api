require 'spec_helper'
require 'duration_parser'

describe DurationParser do
  describe 'to_seconds()' do
    it 'converts a HH:MM:SS string to number of seconds' do
      expect(DurationParser.to_seconds('00:00:46.15')).to eq(46.15)
    end
  end
end
