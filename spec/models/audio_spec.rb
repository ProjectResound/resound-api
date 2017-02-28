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
end
