# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:audios).with_foreign_key('uploader_id') }
  it { is_expected.to validate_presence_of(:nickname) }
  it do
    create(:user)

    is_expected.to validate_uniqueness_of(:uid)
  end

  context 'destroy' do
    it "does not destroy user's Audio" do
      user = User.create(uid: 'userid', nickname: 'nickname')
      Audio.create!(
        title: 'hello world',
        uploader: user,
        filename: 'woohoo boohoo'
      )

      expect do
        user.destroy
      end.to_not change(Audio, 'count')
    end

    it 'does not return the deleted user' do
      user = User.create!(uid: 'userid', nickname: 'nickname')

      expect do
        user.destroy
      end.to change(User, 'count').by(-1)
      expect(User.find_by_uid(user.uid)).to be(nil)
    end
  end

  context 'find_or_create_by_uid' do
    it 'does not create a new user if that uid has been deleted' do
      create_params = { uid: 'uid', nickname: 'nick' }
      user = User.find_or_create_by_uid(create_params)
      user.destroy
      created = nil

      expect do
        created = User.find_or_create_by_uid(create_params)
      end.to_not(change { User.with_deleted.count })
      expect(created).to eq(user)
    end

    it 'creates a new user' do
      user = nil
      create_params = { uid: 'uid', nickname: 'nick' }
      expect do
        user = User.find_or_create_by_uid(create_params)
      end.to change { User.with_deleted.count }.by(1)
      expect(user).to_not be(nil)
    end
  end
end
