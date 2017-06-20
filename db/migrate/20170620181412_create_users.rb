class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users, id: false do |t|
      t.string :uid, null: false
      t.string :nickname
    end

    add_index :users, :uid, unique: true
  end
end