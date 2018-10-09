class AudioProcessing < ActiveJob::Base
  include Resque::Plugins::UniqueJob

  @queue = :medium

  def perform(opts)
    Apartment::Tenant.switch!(opts[:tenant])
    begin
      flow_service = ::FlowService.new(
          identifier: opts[:identifier],
          filename: opts[:filename],
          title: opts[:title],
          contributors: opts[:contributors])

      flow_service.combine_files
      transcoded = flow_service.transcode_file
      if audio = Audio.find_by_filename(opts[:filename])
        audio.duration = transcoded[:duration]
        audio.save

        file_object = {}
        transcoded.each_key do |key|
          case key
          when :final_flac_path
            file_object[:flac] = File.open(transcoded[key])
          when :he_aac_file_path
            file_object[:he_aac] = File.open(transcoded[key])
          when :mp3_file_path
            file_object[:mp3_128] = File.open(transcoded[key])
          end
        end
        audio.update(file: file_object)

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
                                         trace: "Could not find audio: #{opts[:filename]}",
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
