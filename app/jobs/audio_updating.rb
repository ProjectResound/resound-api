# frozen_string_literal: true

class AudioUpdating < ActiveJob::Base
  include Resque::Plugins::UniqueJob

  @queue = :medium

  def perform(audio_id)
    audio = Audio.find_by_id(audio_id)
    return audio.update_metadata if audio
  end
end
