class AddContributorsToAudio < ActiveRecord::Migration[5.0]
  def change
    add_column :audios, :contributors, :string
  end
end
