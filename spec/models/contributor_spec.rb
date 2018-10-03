require 'rails_helper'

RSpec.describe Contributor, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(4) }


  describe "parse_and_process" do
    it "can parse one contributor" do
      contributor_value = 'heart roasters'
      contributors = nil
      expect {
        contributors = Contributor.parse_and_process(contributor_value)
      }.to change{ Contributor.count }.by(1)
      expect(contributors).to eq(contributor_value)
    end

    it "can parse multiple contributors" do
      contributors = nil
      expect {
        contributors = Contributor.parse_and_process('heart roasters, snow white,seven dwarves,')
      }.to change{ Contributor.count }.by(3)
      expect(contributors).to eq('heart roasters, snow white, seven dwarves')
    end

    it "can deal with duplicates" do
      contributors = nil
      the_frame = 'the frame'
      Contributor.parse_and_process(the_frame)
      expect {
        contributors = Contributor.parse_and_process('the Frame')
      }.to change{ Contributor.count }.by(0)
      expect(contributors).to eq(the_frame)
    end
  end
end
