Sequel.migration do
  up do
    extension :pg_triggers

    create_table :audios do
      primary_key :id
      String :title, null: false
      String :filename, null: false, unique: true
      DateTime :created_at
      DateTime :updated_at
      String :file_data, text: true
    end

    pgt_created_at(
        :audios,
        :created_at,
        function_name: :audios_set_created_at,
        trigger_name: :set_created_at
    )
    pgt_updated_at(
        :audios,
        :updated_at,
        function_name: :audios_set_updated_at,
        trigger_name: :set_updated_at
    )
  end

  down do
    drop_table :audios
    drop_trigger(:audios, :set_created_at)
    drop_function(:audios_set_created_at)
    drop_trigger(:audios, :set_updated_at)
    drop_function(:audios_set_updated_at)
  end
end
