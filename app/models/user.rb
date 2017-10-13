class User < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::Serialization
  extend Textacular

  acts_as_paranoid

  has_many :audios,
           foreign_key: 'uploader_id'

  validates :nickname, presence: true

  self.primary_key = 'uid'

  def to_s
    "#<User uid:#{uid}, nickname: \"#{nickname}\">"
  end
end
