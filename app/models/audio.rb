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
    flac = file[:flac]
    return unless flac

    FileUtils.mkpath(updates_file_directory)
    downloaded_file = updates_file_path(id, 'flac')
    open(downloaded_file, 'wb') do |write_file|
      write_file << open(flac.url).read
    end

    transcode_updates(downloaded_file)

    file[:flac].replace(File.open(updates_file_path(File.basename(filename), 'flac')))
    file[:he_aac].replace(File.open(updates_file_path(File.basename(filename), 'm4a')))
    file[:mp3_128].replace(File.open(updates_file_path(File.basename(filename), 'mp3')))
    save

    FileUtils.rm_rf updates_file_directory
  end

  def self.search(query)
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      query.downcase!
      Audio.where("lower(title) LIKE (?)", "%#{query}%").
        or(Audio.where("lower(filename) LIKE (?)", "%#{query}%")).
        or(Audio.where("lower(tags) LIKE (?)", "%#{query}%"))
    else
      super
    end
  end

  private

  def transcode_updates(downloaded_file)
    transcoder = Transcoder.new(
        file: downloaded_file,
        title: title,
        contributor: contributors
    )
    transcoder.transcode(
        output: updates_file_path(File.basename(filename), 'flac'),
        format: Transcoder::FLAC
    )
    transcoder.transcode(
        output: updates_file_path(File.basename(filename), 'mp3'),
        format: Transcoder::MP3_128
    )
    transcoder.transcode(
        output: updates_file_path(File.basename(filename), 'm4a'),
        format: Transcoder::HE_AAC
    )
  end

  def updates_file_directory
    File.join 'tmp', 'updates', id.to_s
  end

  def updates_file_path(identifier, extension = nil)
    if extension
      "#{File.join(updates_file_directory, identifier.to_s)}.#{extension}"
    else
      File.join(updates_file_directory, identifier.to_s)
    end
  end
end
