# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170622172511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audios", force: :cascade do |t|
    t.string   "title",       null: false
    t.string   "uploader_id", null: false
    t.string   "filename",    null: false
    t.string   "file_data"
    t.integer  "duration"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "tags"
    t.index "to_tsvector('english'::regconfig, (title)::text)", name: "index_audios_on_title", using: :gin
    t.index ["filename"], name: "index_audios_on_filename", unique: true, using: :btree
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string   "uid",        null: false
    t.string   "nickname"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    t.index ["uid"], name: "index_users_on_uid", unique: true, using: :btree
  end

end
