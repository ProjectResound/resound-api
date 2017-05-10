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
    duration = stderr.scan(/Duration\:\s([^,]*?),/).last.first

    if !exit_status.success?
      logger.error(stderr)
      raise StandardError, "Unsuccessful command: #{cmd}"
    end

    # Open3.popen3(cmd) do |stdin, stdout, stderr, status|
    #   logger.info(stdout)
    #   unless status.value.success?
    #     logger.error(stderr.read())
    #     raise StandardError, "Unsuccessful command: #{cmd}"
    #   end
    # end

    return duration
  end
end