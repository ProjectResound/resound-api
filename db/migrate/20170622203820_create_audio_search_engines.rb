class CreateAudioSearchEngines < ActiveRecord::Migration[5.0]
  def change
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "postgresql"
      create_view :audio_search_engines
    end
  end
end
