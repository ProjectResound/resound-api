class AudioProcessing
  include Resque::Plugins::UniqueJob
  @queue = :medium

  def self.perform(opts)
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
    end
  end
end