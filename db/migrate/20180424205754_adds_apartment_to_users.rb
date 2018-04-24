class AddsApartmentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :apartment, :string
    add_index :users, :apartment
  end
end
