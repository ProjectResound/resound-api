Sequel.migration do
  change do
    create_table(:audios) do
      primary_key :id
      column :title, "text", :null=>false
      column :filename, "text", :null=>false
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :file_data, "text"
      
      index [:filename], :name=>:audios_filename_key, :unique=>true
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
  end
end
Sequel.migration do
  change do
    self << "SET search_path TO \"$user\", public"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20170228172131_create_audios.rb')"
  end
end
