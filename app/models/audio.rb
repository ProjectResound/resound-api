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

  def update_metadata
    # TODO:
    # 1. download all files associated w/ this audio
    # 2. re-encode with new metadata
    # 3. replace old files with new files
  end
end
