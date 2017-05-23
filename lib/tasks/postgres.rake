# require 'sequel'
# require 'YAML'

namespace :db do
  desc "Adds full_text indexing to columns"

  task add_index: :environment do
    db_cfg = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]
    DB = Sequel.connect("postgres://#{db_cfg['username']}:@#{db_cfg['host']}/#{db_cfg['database']}")

    DB.alter_table :audios do
      add_full_text_index :title, language: 'english'
      add_full_text_index :filename, language: 'english'
    end
  end
end

