class CreateAudios < ActiveRecord::Migration[5.0]
  def up
    create_table :audios do |t|
      t.string :title, null: false
      t.string :filename, null: false
      t.string :file_data, text: true
      t.integer :duration

      t.timestamps
    end
    add_index :audios, :filename, unique: true
    execute "CREATE INDEX index_audios_on_title ON audios USING gin(to_tsvector('english', title));"
  end

  def down
    drop_table :audios

    execute "DROP INDEX index_audios_on_title;"
    execute "DROP INDEX index_audios_on_filename;"
  end
end
