class Audio < ApplicationRecord
  include FileUploader[:file]
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::Serialization

  belongs_to :uploader, class_name: 'User'

  validates :title, presence: true, length: { minimum: 4 }
  validates :filename, presence: true, uniqueness: true

  def self.by_filename(filename)
    where(filename: filename)
  end
end
