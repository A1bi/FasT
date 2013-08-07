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

ActiveRecord::Schema.define(:version => 20130807131502) do

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

  create_table "newsletter_subscribers", :force => true do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "passbook_devices", :force => true do |t|
    t.string   "device_id"
    t.string   "push_token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "passbook_logs", :force => true do |t|
    t.string   "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "passbook_passes", :force => true do |t|
    t.string   "type_id"
    t.string   "serial_number"
    t.string   "auth_token"
    t.string   "path"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "passbook_registrations", :force => true do |t|
    t.integer  "pass_id"
    t.integer  "device_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "ticketing_bank_charges", :force => true do |t|
    t.string   "name"
    t.integer  "number",          :limit => 8
    t.integer  "blz"
    t.string   "bank"
    t.string   "chargeable_type"
    t.integer  "chargeable_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.boolean  "approved",                     :default => false
    t.integer  "submission_id"
  end

  create_table "ticketing_bank_submissions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticketing_blocks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "color",      :default => "black"
  end

  create_table "ticketing_bunches", :force => true do |t|
    t.boolean  "paid"
    t.float    "total"
    t.integer  "cancellation_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "assignable_id"
    t.string   "assignable_type"
    t.integer  "number"
    t.integer  "coupon_id"
  end

  create_table "ticketing_cancellations", :force => true do |t|
    t.string   "reason"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticketing_coupon_ticket_type_assignments", :force => true do |t|
    t.integer  "coupon_id"
    t.integer  "ticket_type_id"
    t.integer  "number"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "ticketing_coupons", :force => true do |t|
    t.string   "code"
    t.string   "expires"
    t.string   "recipient"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticketing_coupons_reservation_groups", :id => false, :force => true do |t|
    t.integer "coupon_id"
    t.integer "reservation_group_id"
  end

  create_table "ticketing_event_dates", :force => true do |t|
    t.datetime "date"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticketing_events", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "identifier"
  end

  create_table "ticketing_log_events", :force => true do |t|
    t.string   "name"
    t.string   "info"
    t.integer  "member_id"
    t.string   "loggable_type"
    t.integer  "loggable_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "ticketing_reservation_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticketing_reservations", :force => true do |t|
    t.datetime "expires"
    t.integer  "date_id"
    t.integer  "seat_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "group_id"
  end

  create_table "ticketing_retail_orders", :force => true do |t|
    t.integer  "store_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "queue_number"
  end

  create_table "ticketing_retail_stores", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticketing_seats", :force => true do |t|
    t.integer  "number"
    t.integer  "row"
    t.integer  "block_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "position_x", :default => 0
    t.integer  "position_y", :default => 0
  end

  create_table "ticketing_ticket_types", :force => true do |t|
    t.string   "name"
    t.float    "price"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "info"
    t.boolean  "exclusive",  :default => false
  end

  create_table "ticketing_tickets", :force => true do |t|
    t.integer  "number"
    t.float    "price"
    t.integer  "bunch_id"
    t.integer  "cancellation_id"
    t.integer  "type_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "seat_id"
    t.integer  "date_id"
  end

  create_table "ticketing_web_orders", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "gender"
    t.string   "phone"
    t.string   "plz"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "pay_method"
  end

end
