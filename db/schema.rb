# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130325133347) do

  create_table "galleries", :force => true do |t|
    t.string   "title"
    t.string   "disclaimer"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "gbook_entries", :force => true do |t|
    t.string   "author"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members_members", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "group"
    t.datetime "last_login"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "activation_code"
    t.date     "birthday"
    t.string   "nickname"
  end

  create_table "members_dates", :force => true do |t|
    t.datetime "datetime"
    t.string   "info"
    t.string   "location"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members_files", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "path"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "photos", :force => true do |t|
    t.string   "text"
    t.integer  "position"
    t.integer  "gallery_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "is_slide",           :default => false
  end

end
