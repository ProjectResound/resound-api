require 'rails_helper'

RSpec.describe Audio, type: :model do
  before(:each) do
    @uploader = User.create(uid: '123', nickname: 'louise')
  end

  it "is not valid without a title"  do
    audio = Audio.new(title: nil)
    expect(audio).to_not be_valid
  end

  it "is not valid when title is too short" do
    audio = Audio.new(title: 'boo')
    expect(audio).to_not be_valid
  end

  it "is valid with valid attributes" do
    expect(Audio.new(filename: 'file.wav', title: 'title')).to be_valid
  end

  describe "search" do
    it "returns a result if there is a match" do
      audio = create(:audio, title: 'hello world', uploader: @uploader)
      results = Audio.search('hello')

      expect(results).to exist
      expect(results.first.id).to be(audio.id)
    end

    it "returns an empty array if there is no match" do
      expect(Audio.search('mojitos')).to be_empty
    end
  end
end
