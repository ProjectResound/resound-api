require 'rails_helper'

RSpec.describe User, type: :model do
  context "destroy()" do
    it "does not destroy user's Audio" do
      user = User.create(uid: 'userid', nickname: 'nickname')
      audio = Audio.create(title: 'hello world', uploader: user)

      expect {
        user.destroy
      }.to_not change(Audio, 'count')
    end

    it "does not return the deleted user" do
      user = User.create(uid: 'userid', nickname: 'nickname')

      expect {
        user.destroy
      }.to change{ User.count }.by(-1)
      expect(User.find_by_uid(user.uid)).to be(nil)
    end
  end
end
