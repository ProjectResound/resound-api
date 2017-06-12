class AddTagsToAudios < ActiveRecord::Migration[5.0]
  def change
    add_column :audios, :tags, :string
  end
end
