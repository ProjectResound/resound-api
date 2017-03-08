require 'rails_helper'

RSpec.describe Audio, type: :model do
  it "is not valid without a title"  do
    audio = Audio.new(title: nil)
    expect(audio).to_not be_valid
  end

  it "is not valid when title is too short" do
    audio = Audio.new(title: 'boo')
    expect(audio).to_not be_valid
  end

  it "is valid with valid attributes" do
    expect(Audio.new(title: 'title')).to be_valid
  end

  describe "first_by_filename" do
    it "returns nil when no records are found" do
      expect(Audio.first_by_filename('something.wav')).to be_nil
    end

    it "returns an object with that filename" do
      filename = 'file.name'
      audio = Audio.create(title: 'walla', filename: filename)
      expect(Audio.first_by_filename(filename).id).to be(audio.id)
    end
  end
end
