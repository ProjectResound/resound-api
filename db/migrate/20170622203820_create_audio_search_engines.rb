class CreateAudioSearchEngines < ActiveRecord::Migration[5.0]
  def change
    create_view :audio_search_engines
  end
end
