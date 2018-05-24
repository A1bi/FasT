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

ActiveRecord::Schema.define(version: 2018_05_21_105047) do

  create_table "documents", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.integer "members_group", default: 0
  end

  create_table "galleries", force: :cascade do |t|
    t.string "title"
    t.string "disclaimer"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gbook_entries", force: :cascade do |t|
    t.string "author"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members_dates", force: :cascade do |t|
    t.datetime "datetime"
    t.text "info"
    t.string "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
  end

  create_table "members_members", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.integer "group", default: 0
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "activation_code"
    t.date "birthday"
    t.string "nickname"
  end

  create_table "newsletter_images", force: :cascade do |t|
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "newsletter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["newsletter_id"], name: "index_newsletter_images_on_newsletter_id"
  end

  create_table "newsletter_newsletters", force: :cascade do |t|
    t.string "subject"
    t.text "body_html"
    t.text "body_text"
    t.datetime "sent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsletter_newsletters_subscriber_lists", id: false, force: :cascade do |t|
    t.integer "newsletter_id"
    t.integer "subscriber_list_id"
    t.index ["newsletter_id"], name: "index_newsletter_newsletters_subscriber_lists_on_letter_id"
    t.index ["subscriber_list_id"], name: "index_newsletter_newsletters_subscriber_lists_on_list_id"
  end

  create_table "newsletter_subscriber_lists", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.string "email"
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "gender"
    t.string "last_name"
    t.integer "subscriber_list_id", default: 1, null: false
    t.datetime "confirmed_at"
    t.index ["subscriber_list_id"], name: "index_newsletter_subscribers_on_subscriber_list_id"
  end

  create_table "passbook_devices", force: :cascade do |t|
    t.string "device_id"
    t.string "push_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["device_id"], name: "index_passbook_devices_on_device_id", unique: true
  end

  create_table "passbook_logs", force: :cascade do |t|
    t.text "message", limit: 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "passbook_passes", force: :cascade do |t|
    t.string "type_id"
    t.string "serial_number"
    t.string "auth_token"
    t.string "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "assignable_id"
    t.string "assignable_type"
  end

  create_table "passbook_registrations", force: :cascade do |t|
    t.integer "pass_id"
    t.integer "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: :cascade do |t|
    t.string "text"
    t.integer "position"
    t.integer "gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "is_slide", default: false
  end

  create_table "ticketing_bank_charges", force: :cascade do |t|
    t.string "name"
    t.string "iban"
    t.string "chargeable_type"
    t.integer "chargeable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "approved", default: false
    t.integer "submission_id"
    t.decimal "amount", default: "0.0", null: false
  end

  create_table "ticketing_bank_submissions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_billing_accounts", force: :cascade do |t|
    t.decimal "balance", default: "0.0", null: false
    t.integer "billable_id", null: false
    t.string "billable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billable_id", "billable_type"], name: "index_billing_acounts_on_id_and_type"
  end

  create_table "ticketing_billing_transfers", force: :cascade do |t|
    t.decimal "amount", default: "0.0", null: false
    t.string "note_key"
    t.integer "account_id", null: false
    t.integer "participant_id"
    t.integer "reverse_transfer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ticketing_billing_transfers_on_account_id"
    t.index ["participant_id"], name: "index_ticketing_billing_transfers_on_participant_id"
  end

  create_table "ticketing_blocks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "color", default: "black"
    t.integer "seating_id", default: 1, null: false
  end

  create_table "ticketing_box_office_box_offices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_checkpoints", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_order_payments", force: :cascade do |t|
    t.decimal "amount", default: "0.0", null: false
    t.integer "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_products", force: :cascade do |t|
    t.string "name"
    t.float "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_purchase_items", force: :cascade do |t|
    t.integer "purchase_id"
    t.integer "purchasable_id"
    t.string "purchasable_type"
    t.float "total"
    t.integer "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_box_office_purchases", force: :cascade do |t|
    t.integer "box_office_id"
    t.float "total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "pay_method"
  end

  create_table "ticketing_cancellations", force: :cascade do |t|
    t.string "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_check_ins", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "checkpoint_id"
    t.integer "medium"
    t.datetime "date"
  end

  create_table "ticketing_coupon_redemptions", force: :cascade do |t|
    t.integer "coupon_id", null: false
    t.integer "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ticketing_coupons", force: :cascade do |t|
    t.string "code"
    t.datetime "expires", precision: 255
    t.string "recipient"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "free_tickets", default: 0
  end

  create_table "ticketing_coupons_reservation_groups", id: false, force: :cascade do |t|
    t.integer "coupon_id"
    t.integer "reservation_group_id"
  end

  create_table "ticketing_event_dates", force: :cascade do |t|
    t.datetime "date"
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_events", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "identifier"
    t.datetime "sale_start"
    t.integer "seating_id", default: 1, null: false
    t.string "location"
  end

  create_table "ticketing_log_events", force: :cascade do |t|
    t.string "name"
    t.string "info"
    t.integer "member_id"
    t.string "loggable_type"
    t.integer "loggable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_orders", force: :cascade do |t|
    t.integer "number"
    t.boolean "paid", default: false, null: false
    t.decimal "total", default: "0.0", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
    t.string "phone"
    t.string "plz"
    t.integer "pay_method", limit: 255
    t.integer "store_id"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "box_office_id"
  end

  create_table "ticketing_push_notifications_devices", force: :cascade do |t|
    t.string "token"
    t.string "app"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "settings"
  end

  create_table "ticketing_reservation_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_reservations", force: :cascade do |t|
    t.datetime "expires"
    t.integer "date_id"
    t.integer "seat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "group_id"
  end

  create_table "ticketing_retail_stores", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_digest"
  end

  create_table "ticketing_seatings", force: :cascade do |t|
    t.integer "number_of_seats", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_seats", force: :cascade do |t|
    t.integer "number"
    t.integer "row"
    t.integer "block_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position_x", default: 0
    t.integer "position_y", default: 0
  end

  create_table "ticketing_signing_keys", force: :cascade do |t|
    t.string "secret", limit: 32, default: "", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketing_ticket_types", force: :cascade do |t|
    t.string "name"
    t.decimal "price", default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "info"
    t.boolean "exclusive", default: false
  end

  create_table "ticketing_tickets", force: :cascade do |t|
    t.decimal "price", default: "0.0", null: false
    t.integer "order_id"
    t.integer "cancellation_id"
    t.integer "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "seat_id"
    t.integer "date_id"
    t.boolean "picked_up", default: false
    t.boolean "resale", default: false
    t.boolean "invalidated", default: false
    t.integer "order_index", default: 0, null: false
    t.index ["order_id", "order_index"], name: "index_ticketing_tickets_on_order_id_and_order_index", unique: true
  end

end
