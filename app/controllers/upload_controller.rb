class UploadController < ApplicationController
  require 'transcoder'

  FFMPEG_PATH = Rails.application.config.store_manage[:ffmpeg_path]

  def index
  end

  def post
    save_file!
    if last_chunk?
      combine_file!
      transcode_file!
      create_new_audio
      cleanup!
      render status: :created, json: {
          fileSize: File.size(final_flac_path),
          url: final_flac_path
      }
      return
    end

    render status: :ok
  end

  private

  def save_file!
    # Ensure required paths exist
    FileUtils.mkpath chunk_file_directory
    # Move the temporary file upload to the temporary chunk file path
    FileUtils.mv params['file'].tempfile, chunk_file_path(params[:flowFilename], params[:flowChunkNumber]), force: true
  end

  def last_chunk?
    for i in 1..params[:flowTotalChunks].to_i
      if !File.exists?(chunk_file_path(params[:flowFilename], i))
        return false
      end
    end
    return true
  end

  def chunk_file_path(fileName, number)
    File.join(chunk_file_directory, "#{fileName}.part#{number}")
  end

  def chunk_file_directory
    File.join "tmp", "flow", params[:flowIdentifier]
  end

  def combine_file!
    # Ensure required paths exist
    FileUtils.mkpath final_file_directory
    # Remove any existing file so that we don't keep appending to an old file.
    FileUtils.rm final_file_path, force: true
    # Open final file in append mode
    File.open(final_file_path, "a") do |f|
      file_chunks.each do |file_chunk_path|
        # Write each chunk to the permanent file
        f.write File.read(file_chunk_path)
      end
    end
  end

  def transcode_file!
    transcoder = Transcoder.new()
    transcoder.binary_path = FFMPEG_PATH
    transcoder.to_flac(
      file: final_file_path,
      output_file: final_flac_path,
      title: params[:title],
      contributor: params[:contributor]
    )
  end

  def create_new_audio
    audio = Audio.new(
      title: params[:title],
      filename: params[:flowFilename],
      file: File.open(final_flac_path)
    )
    audio.save
  end

  def cleanup!
    # Cleanup chunk file directory and all chunk files
    FileUtils.rm_rf chunk_file_directory
  end

  def final_file_path
    File.join final_file_directory, params[:flowFilename]
  end

  def final_flac_path
    "#{final_file_path}.flac"
  end

  def final_file_directory
    File.join "tmp", "final"
  end

  def file_chunks
    Dir["#{chunk_file_directory}/*.part*"].sort_by {|f| f.split(".part")[1].to_i }
  end
end
