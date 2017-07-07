class CreateContributors < ActiveRecord::Migration[5.0]
  def change
    create_table :contributors do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :contributors, :name, unique: true
  end
end
