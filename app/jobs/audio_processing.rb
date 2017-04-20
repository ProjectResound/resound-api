class AudioProcessing
  include Resque::Plugins::UniqueJob
  @queue = :medium

  def self.perform(opts)
    begin
      flow_service = ::FlowService.new(
          identifier: opts['identifier'],
          filename: opts['filename'],
          title: opts['title'],
          contributor: opts['contributor'])

      flow_service.combine_files
      file_path = flow_service.transcode_file

      if audio = Audio.first(filename: opts['filename'])
        audio.file = File.open(file_path)
        audio.save
        flow_service.clean
        ActionCable.server.broadcast 'FilesChannel',
                                     {
                                       audio_id: audio.id,
                                       status: 'success',
                                       filename: opts['filename']
                                     }
      end
    rescue StandardError => error
      ActionCable.server.broadcast 'FilesChannel',
                                    {
                                        status: 'failed',
                                        trace: error,
                                        filename: opts['filename']
                                    }
    end
  end
end