class CreateAudios < ActiveRecord::Migration[5.0]
  def up
    create_table :audios do |t|
      t.string :title, null: false
      t.string :uploader_id, null: false
      t.string :filename, null: false
      t.text :file_data
      t.integer :duration

      t.timestamps
    end
    add_index :audios, :filename, unique: true
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "CREATE FULLTEXT INDEX index_audios_on_title ON audios(title);"
    elsif ActiveRecord::Base.connection.instance_values["config"][:adapter] == "postgresql"
      execute "CREATE INDEX index_audios_on_title ON audios USING gin(to_tsvector('english', title));"
    end
  end

  def down
    drop_table :audios

    execute "DROP INDEX index_audios_on_title;"
    execute "DROP INDEX index_audios_on_filename;"
  end
end
