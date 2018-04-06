class Transcoder
  require 'open3'
  require 'streamio-ffmpeg'

  FLAC = 'flac'
  MP3_128 = '128-mp3'
  HE_AAC = 'he-aac'

  def initialize(file:, title:, contributor:)
    unless File.exists?(file)
      raise StandardError, "File does not exist: #{file}"
    end

    @file = FFMPEG::Movie.new(file)
    @title = title
    @contributor = contributor
    FFMPEG.ffmpeg_binary = Rails.application.config.store_manage[:ffmpeg_path]
  end

  def logger
    Rails.logger
  end

  def transcode(output:, format:)
    encoding_options = {}
    case format
      when HE_AAC
        encoding_options.merge!({
                                  audio_codec: 'libfdk_aac',
                                  audio_bitrate: '48'
                                })
      when MP3_128
        encoding_options.merge!({
                                  audio_codec: 'libmp3lame',
                                  audio_bitrate: '128',
                                  audio_bitdepth: '16',
                                  audio_channels: '2'
                                })
    end
    encoding_options.merge!({custom:  %W(-metadata title=#{@title} -metadata artist=#{@contributor})
                            })
    @file.transcode(output, encoding_options)
    @file.duration
  end

  def get_duration
    @file.duration
  end


end