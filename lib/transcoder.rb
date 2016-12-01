class Transcoder
  require 'open3'

  def initialize

  end

  def logger
    Rails.logger
  end

  def binary_path=(path)
    if File.exists?(path)
      @binary_path = path
    else
      raise ArgumentError, "Not a valid path", caller
    end
  end

  def to_flac(file, output_file)
    unless @binary_path
      raise StandardError, "No valid binary_path", caller
    end
    unless File.exists?(file)
      raise StandardError, "File does not exist: #{file}"
    end

    cmd = "#{@binary_path} -y -i '#{file}' '#{output_file}'"
    Open3.popen3(cmd) do |stdin, stdout, stderr, status|
      unless status.value.success?
        logger.error(stderr.read())
        raise StandardError, "Unsuccessful command: #{cmd}"
      end
    end
    return output_file
  end
end