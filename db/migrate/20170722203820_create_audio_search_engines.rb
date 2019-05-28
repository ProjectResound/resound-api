class CreateAudioSearchEngines < ActiveRecord::Migration[5.0]
  def change
    return if ActiveRecord::Base.connection.view_exists? 'audio_search_engines'

    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "postgresql"
      create_view :audio_search_engines
    elsif ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "CREATE VIEW audio_search_engines AS SELECT
  audios.id AS id,
  audios.title AS title,
  audios.filename AS filename,
  audios.tags AS tags,
  audios.contributors AS contributors,
  audios.duration as duration,
  audios.created_at as created_at,
  users.nickname AS uploader_nickname
FROM audios
JOIN users ON audios.uploader_id = users.uid
;"
    end

  end
end
