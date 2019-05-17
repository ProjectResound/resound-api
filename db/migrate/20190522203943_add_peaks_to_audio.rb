class AddPeaksToAudio < ActiveRecord::Migration[5.0]
  def change
    add_column :audios, :peaks, :string
  end
end
