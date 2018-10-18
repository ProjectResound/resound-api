# frozen_string_literal: true

class FlowService
  require 'transcoder'

  attr_reader :identifier,
              :filename,
              :title,
              :contributors

  def initialize(identifier:, filename:, title:, contributors:)
    @identifier = identifier
    @filename = filename
    @title = title
    @contributor = contributors
  end

  # If the original file is a wav, run it through transcoding process,
  # if it's an mp3, do nothing but return the same file structure.
  def transcode_file
    transcoder = Transcoder.new(
      file: final_file_path,
      title: @title,
      contributor: @contributor
    )
    duration = transcoder.duration

    if File.extname(@filename) == '.wav'
      transcoder.transcode(
        output: final_flac_path,
        format: Transcoder::FLAC
      )
      transcoder.transcode(
        output: mp3_file_path,
        format: Transcoder::MP3_128
      )
      transcoder.transcode(
        output: he_aac_file_path,
        format: Transcoder::HE_AAC
      )
      {
        final_flac_path: final_flac_path,
        he_aac_file_path: he_aac_file_path,
        mp3_file_path: mp3_file_path,
        duration: duration
      }
    else
      {
        mp3_file_path: final_file_path,
        duration: duration
      }
    end
  end

  def combine_files
    # Ensure required paths exist
    FileUtils.mkpath final_file_directory
    # Remove any existing file so that we don't keep appending to an old file.
    FileUtils.rm final_file_path, force: true
    # Open final file in append mode
    File.open(final_file_path, 'a') do |f|
      file_chunks.each do |file_chunk_path|
        # Write each chunk to the permanent file
        f.write File.read(file_chunk_path)
      end
    end
  end

  def clean
    FileUtils.rm_rf chunk_file_directory
    [final_file_path, final_flac_path, mp3_file_path, he_aac_file_path]
      .each do |file|
      FileUtils.remove file if File.exist?(file)
    end
    true
  end

  private

  def chunk_file_directory
    File.join 'tmp', 'flow', @identifier
  end

  def file_chunks
    Dir["#{chunk_file_directory}/*.part*"]
      .sort_by { |f| f.split('.part')[1].to_i }
  end

  def final_file_path
    File.join final_file_directory, File.basename(@filename)
  end

  def final_flac_path
    "#{final_file_path}.flac"
  end

  def mp3_file_path
    "#{final_file_path}.128k.mp3"
  end

  def he_aac_file_path
    "#{final_file_path}.he-aac.m4a"
  end

  def final_file_directory
    File.join 'tmp', 'final'
  end
end
