class FlowService
  require 'transcoder'

  attr_reader :identifier,
              :filename,
              :title,
              :contributor

  def initialize(identifier:, filename:, title:, contributor:)
    @identifier = identifier
    @filename = filename
    @title = title
    @contributor = contributor
  end

  def transcode_file
    transcoder = Transcoder.new()
    duration = transcoder.to_flac(
        file: final_file_path,
        output_file: final_flac_path,
        title: @title,
        contributor: @contributor
    )
    return { final_flac_path: final_flac_path, duration: duration }
  end

  def combine_files
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

  def clean
    FileUtils.rm_rf chunk_file_directory
    FileUtils.remove final_file_path
    true
  end

  private

    def chunk_file_directory
      File.join 'tmp', 'flow', @identifier
    end

    def file_chunks
      Dir["#{chunk_file_directory}/*.part*"].sort_by {|f| f.split(".part")[1].to_i }
    end

    def final_file_path
      File.join final_file_directory, @filename
    end

    def final_flac_path
      "#{final_file_path}.flac"
    end

    def final_file_directory
        File.join "tmp", "final"
    end
end