class Audio < ApplicationRecord
  include FileUploader[:file]
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::Serialization

  extend Textacular

  belongs_to :uploader, class_name: 'User'

  validates :title, presence: true, length: { minimum: 4 }
  validates :filename, presence: true, uniqueness: true

  def self.by_filename(filename)
    where(filename: filename)
  end
  
  def self.update_or_create_by_filename(opts = {})
    if audio = by_filename(opts[:filename]).first
      audio.title = opts[:title]
      audio.tags = opts[:tags]
      audio.uploader = opts[:uploader]
    else
      audio = new(
          title: opts[:title],
          filename: opts[:filename],
          tags: opts[:tags],
          uploader: opts[:uploader])
    end
    audio.save
    return audio
  end
end
