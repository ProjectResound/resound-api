class UpdateAudioSearchEnginesToVersion2 < ActiveRecord::Migration[5.0]
  def change
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "postgresql"
      update_view :audio_search_engines, version: 2, revert_to_version: 1
    end
  end
end
