require 'rails_helper'

RSpec.describe Audio, type: :model do
  it { is_expected.to belong_to(:uploader).class_name('User') }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_least(4) }
  it { is_expected.to validate_presence_of(:filename) }

  it do
    create(:audio)

    is_expected.to validate_uniqueness_of(:filename)
  end


  describe '.by_filename' do
    it 'returns audions that matches with the filename' do
      audio1 = create(:audio)
      audio2 = create(:audio, filename: 'newFilename.mp3')

      expect(Audio.by_filename('newFilename.mp3')).to include audio2
    end
  end


  describe "#search" do
    it "returns a result if there is a match" do
      audio = create(:audio, title: 'hello world')
      results = Audio.search('hello')

      expect(results).to exist
      expect(results.first.id).to be(audio.id)
    end

    it "returns an empty array if there is no match" do
      expect(Audio.search('mojitos')).to be_empty
    end
  end
end
