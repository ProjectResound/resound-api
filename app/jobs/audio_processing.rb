class AudioProcessing < ActiveJob::Base
  include Resque::Plugins::UniqueJob

  @queue = :medium

  def perform(opts)
    begin
      flow_service = ::FlowService.new(
          identifier: opts[:identifier],
          filename: opts[:filename],
          title: opts[:title],
          contributors: opts[:contributors])

      flow_service.combine_files
      transcoded = flow_service.transcode_file
      if audio = Audio.find_by_filename(opts[:filename])
        if !audio.file
          # This is a brand new upload
          audio.file = {
              flac: File.open(transcoded[:final_flac_path]),
              he_aac: File.open(transcoded[:he_aac_file_path]),
              mp3_128: File.open(transcoded[:mp3_file_path])
          }
        else
          # We're replacing it with new audio
          audio.file[:flac].replace(File.open(transcoded[:final_flac_path]))
          audio.file[:he_aac].replace(File.open(transcoded[:he_aac_file_path]))
          audio.file[:mp3_128].replace(File.open(transcoded[:mp3_file_path]))
        end
        audio.duration = transcoded[:duration]
        audio.save
        flow_service.clean
        ActionCable.server.broadcast 'FilesChannel',
                                     {
                                       audio_id: audio.id,
                                       status: 'success',
                                       filename: opts[:filename],
                                       contributors: opts[:contributors]
                                     }
      else
        ActionCable.server.broadcast 'FilesChannel',
                                     {
                                         status: 'failed',
                                         trace: "Could not find audio id: #{audio.id}",
                                         filename: opts[:filename]
                                     }
      end
    rescue StandardError => error
      ActionCable.server.broadcast 'FilesChannel',
                                    {
                                        status: 'failed',
                                        trace: error,
                                        filename: opts[:filename]
                                    }
    end
  end
end