class Audio < ApplicationRecord
  include FileUploader[:file]
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::Serialization

  require 'open-uri'
  require 'transcoder'

  belongs_to :uploader, class_name: 'User'

  validates :title, presence: true, length: { minimum: 4 }
  validates :filename, presence: true, uniqueness: true

  def self.by_filename(filename)
    where(filename: filename)
  end

  def update_metadata
    file.each do |type, uploaded_file|
      next unless uploaded_file.url
      FileUtils.mkpath(updates_file_directory)
      open(updates_file_path(uploaded_file.extension), 'wb') do |write_file|
        write_file << open(uploaded_file.url).read
      end
      # transcoder = Transcoder.new(
      #     file: uploaded_file.url,
      #     title: title,
      #     contributor: contributors
      # )
    end
    # TODO:
    # 1. download all files associated w/ this audio
    # 2. re-encode with new metadata
    # 3. replace old files with new files
  end

  private

  def updates_file_directory
    File.join 'tmp', 'updates', id.to_s
  end

  def updates_file_path(extension)
    "#{File.join(updates_file_directory, id.to_s)}.#{extension}"
  end
end
