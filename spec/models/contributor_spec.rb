require 'rails_helper'

RSpec.describe Contributor, type: :model do

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
      Contributor.create(name: 'Agatha Christie')
      expect {
        contributors = Contributor.parse_and_process('agatha christie')
      }.to change{ Contributor.count }.by(0)
      expect(contributors).to eq('agatha christie')
    end
  end
end
