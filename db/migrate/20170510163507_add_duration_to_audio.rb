Sequel.migration do
  change do
    alter_table :audios do
      add_column :duration, :decimal, precision: 2
    end
  end
end
