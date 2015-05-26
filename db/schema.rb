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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150524120013) do

  create_table "galleries", force: :cascade do |t|
    t.string   "title"
    t.string   "disclaimer"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gbook_entries", force: :cascade do |t|
    t.string   "author"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members_dates", force: :cascade do |t|
    t.datetime "datetime"
    t.text     "info"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "members_files", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "members_members", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "group"
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_code"
    t.date     "birthday"
    t.string   "nickname"
  end

  create_table "newsletter_newsletters", force: :cascade do |t|
    t.string   "subject"
    t.text     "body_html"
    t.text     "body_text"
    t.datetime "sent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gender"
    t.string   "last_name"
  end

  create_table "passbook_devices", force: :cascade do |t|
    t.string   "device_id"
    t.string   "push_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "passbook_logs", force: :cascade do |t|
    t.text     "message",    limit: 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "passbook_passes", force: :cascade do |t|
    t.string   "type_id"
    t.string   "serial_number"
    t.string   "auth_token"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignable_id"
    t.string   "assignable_type"
  end

  create_table "passbook_registrations", force: :cascade do |t|
    t.integer  "pass_id"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: :cascade do |t|
    t.string   "text"
    t.integer  "position"
    t.integer  "gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "is_slide",           default: false
  end

  create_table "ticketing_bank_charges", force: :cascade do |t|
    t.string   "name"
    t.string   "iban"
    t.string   "chargeable_type"
    t.integer  "chargeable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",        default: false
    t.integer  "submission_id"
    t.decimal  "amount",          default: 0.0,   null: false
  end

  create_table "ticketing_bank_submissions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_billing_accounts", force: :cascade do |t|
    t.decimal  "balance",       default: 0.0, null: false
    t.integer  "billable_id",                 null: false
    t.string   "billable_type",               null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "ticketing_billing_accounts", ["billable_id", "billable_type"], name: "index_billing_acounts_on_id_and_type"

  create_table "ticketing_billing_transfers", force: :cascade do |t|
    t.decimal  "amount",              default: 0.0, null: false
    t.string   "note_key"
    t.integer  "account_id",                        null: false
    t.integer  "participant_id"
    t.integer  "reverse_transfer_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "ticketing_billing_transfers", ["account_id"], name: "index_ticketing_billing_transfers_on_account_id"
  add_index "ticketing_billing_transfers", ["participant_id"], name: "index_ticketing_billing_transfers_on_participant_id"

  create_table "ticketing_blocks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",      default: "black"
  end

  create_table "ticketing_box_office_box_offices", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_checkins", force: :cascade do |t|
    t.integer  "ticket_id"
    t.integer  "checkpoint_id"
    t.boolean  "in"
    t.integer  "medium"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_checkpoints", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_products", force: :cascade do |t|
    t.string   "name"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_purchase_items", force: :cascade do |t|
    t.integer  "purchase_id"
    t.integer  "purchasable_id"
    t.string   "purchasable_type"
    t.float    "total"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_purchases", force: :cascade do |t|
    t.integer  "box_office_id"
    t.float    "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_cancellations", force: :cascade do |t|
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_coupon_ticket_type_assignments", force: :cascade do |t|
    t.integer  "coupon_id"
    t.integer  "ticket_type_id"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_coupons", force: :cascade do |t|
    t.string   "code"
    t.datetime "expires"
    t.string   "recipient"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_coupons_reservation_groups", id: false, force: :cascade do |t|
    t.integer "coupon_id"
    t.integer "reservation_group_id"
  end

  create_table "ticketing_event_dates", force: :cascade do |t|
    t.datetime "date"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_events", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.datetime "sale_start"
  end

  create_table "ticketing_log_events", force: :cascade do |t|
    t.string   "name"
    t.string   "info"
    t.integer  "member_id"
    t.string   "loggable_type"
    t.integer  "loggable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_orders", force: :cascade do |t|
    t.integer  "number"
    t.boolean  "paid",       default: false, null: false
    t.decimal  "total",      default: 0.0,   null: false
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "gender"
    t.string   "phone"
    t.string   "plz"
    t.integer  "pay_method"
    t.integer  "coupon_id"
    t.integer  "store_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_push_notifications_devices", force: :cascade do |t|
    t.string   "token"
    t.string   "app"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_reservation_groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_reservations", force: :cascade do |t|
    t.datetime "expires"
    t.integer  "date_id"
    t.integer  "seat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  create_table "ticketing_retail_stores", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
  end

  create_table "ticketing_seats", force: :cascade do |t|
    t.integer  "number"
    t.integer  "row"
    t.integer  "block_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position_x", default: 0
    t.integer  "position_y", default: 0
  end

  create_table "ticketing_ticket_types", force: :cascade do |t|
    t.string   "name"
    t.decimal  "price",      default: 0.0,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "info"
    t.boolean  "exclusive",  default: false
  end

  create_table "ticketing_tickets", force: :cascade do |t|
    t.integer  "number"
    t.decimal  "price",           default: 0.0,   null: false
    t.integer  "order_id"
    t.integer  "cancellation_id"
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seat_id"
    t.integer  "date_id"
    t.boolean  "paid",            default: false
    t.boolean  "picked_up",       default: false
  end

end
