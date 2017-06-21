class Transcoder
  require 'open3'

  def initialize
    @binary_path = Rails.application.config.store_manage[:ffmpeg_path]
  end

  def logger
    Rails.logger
  end

  def to_flac(file:, output_file:, title:, contributor:)
    unless @binary_path
      raise StandardError, "No valid binary_path", caller
    end
    unless File.exists?(file)
      raise StandardError, "File does not exist: #{file}"
    end

    cmd = "#{@binary_path} -y -i '#{file}' -metadata title=\"#{title}\"" +
        " -metadata artist=\"#{contributor}\" '#{output_file}'"

    stdout, stderr, exit_status = Open3.capture3(cmd)
    if duration_line = stderr.scan(/Duration\:\s([^,]*?),/).last
      duration = duration_line.first
    end

    if !exit_status.success?
      logger.error(stderr)
      raise StandardError, "Unsuccessful command: #{cmd}"
    end

    return duration
  end
end