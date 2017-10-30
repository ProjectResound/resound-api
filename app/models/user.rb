class User < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::Serialization
  extend Textacular

  acts_as_paranoid

  has_many :audios,
           foreign_key: 'uploader_id'

  validates :nickname, presence: true
  validates :uid, uniqueness: true

  self.primary_key = 'uid'

  def self.find_or_create_by_uid(uid:, nickname:)
    if deleted_user = User.only_deleted.where(uid: uid).first
      deleted_user.recover
      deleted_user.nickname = nickname
      return deleted_user
    end
    return User.create(uid: uid, nickname: nickname)
  end

  private

  def to_s
    "#<User uid:#{uid}, nickname: \"#{nickname}\">"
  end
end
