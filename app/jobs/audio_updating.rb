class AudioUpdating < ActiveJob::Base
  include Resque::Plugins::UniqueJob

  @queue = :medium

  def perform(audio_id)
    if audio = Audio.find_by_id(audio_id)
      audio.update_metadata
    end
  end
end
