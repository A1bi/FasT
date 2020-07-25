# frozen_string_literal: true

class AddForeignKeys < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id

    add_foreign_key :members_exclusive_ticket_type_credit_spendings, :users, column: :member_id
    add_foreign_key :members_exclusive_ticket_type_credit_spendings, :ticketing_ticket_types, column: :ticket_type_id
    add_foreign_key :members_exclusive_ticket_type_credit_spendings, :ticketing_orders, column: :order_id

    add_foreign_key :members_exclusive_ticket_type_credits, :ticketing_ticket_types, column: :ticket_type_id

    add_foreign_key :newsletter_images, :newsletter_newsletters, column: :newsletter_id

    add_foreign_key :newsletter_newsletters_subscriber_lists, :newsletter_newsletters, column: :newsletter_id
    add_foreign_key :newsletter_newsletters_subscriber_lists, :newsletter_subscriber_lists, column: :subscriber_list_id

    add_foreign_key :newsletter_subscribers, :newsletter_subscriber_lists, column: :subscriber_list_id

    add_foreign_key :passbook_registrations, :passbook_passes, column: :pass_id
    add_foreign_key :passbook_registrations, :passbook_devices, column: :device_id

    add_foreign_key :photos, :galleries

    add_foreign_key :ticketing_bank_charges, :ticketing_bank_submissions, column: :submission_id

    add_foreign_key :ticketing_billing_transfers, :ticketing_billing_accounts, column: :account_id
    add_foreign_key :ticketing_billing_transfers, :ticketing_billing_accounts, column: :participant_id
    add_foreign_key :ticketing_billing_transfers, :ticketing_billing_transfers, column: :reverse_transfer_id

    add_foreign_key :ticketing_blocks, :ticketing_seatings, column: :seating_id

    add_foreign_key :ticketing_box_office_order_payments, :ticketing_orders, column: :order_id

    add_foreign_key :ticketing_box_office_purchase_items, :ticketing_box_office_purchases, column: :purchase_id

    add_foreign_key :ticketing_box_office_purchases, :ticketing_box_office_box_offices, column: :box_office_id

    add_foreign_key :ticketing_check_ins, :ticketing_tickets, column: :ticket_id
    add_foreign_key :ticketing_check_ins, :ticketing_box_office_checkpoints, column: :checkpoint_id

    add_foreign_key :ticketing_coupon_redemptions, :ticketing_coupons, column: :coupon_id
    add_foreign_key :ticketing_coupon_redemptions, :ticketing_orders, column: :order_id

    add_foreign_key :ticketing_coupons_reservation_groups, :ticketing_coupons, column: :coupon_id
    add_foreign_key :ticketing_coupons_reservation_groups, :ticketing_reservation_groups, column: :reservation_group_id

    add_foreign_key :ticketing_event_dates, :ticketing_events, column: :event_id

    add_foreign_key :ticketing_events, :ticketing_seatings, column: :seating_id

    add_foreign_key :ticketing_log_events, :users, column: :user_id

    add_foreign_key :ticketing_orders, :ticketing_retail_stores, column: :store_id
    add_foreign_key :ticketing_orders, :ticketing_box_office_box_offices, column: :box_office_id
    add_foreign_key :ticketing_orders, :ticketing_event_dates, column: :date_id

    add_foreign_key :ticketing_reservations, :ticketing_event_dates, column: :date_id
    add_foreign_key :ticketing_reservations, :ticketing_seats, column: :seat_id
    add_foreign_key :ticketing_reservations, :ticketing_reservation_groups, column: :group_id

    add_foreign_key :ticketing_seats, :ticketing_blocks, column: :block_id

    add_foreign_key :ticketing_ticket_types, :ticketing_events, column: :event_id

    add_foreign_key :ticketing_tickets, :ticketing_orders, column: :order_id
    add_foreign_key :ticketing_tickets, :ticketing_cancellations, column: :cancellation_id
    add_foreign_key :ticketing_tickets, :ticketing_ticket_types, column: :type_id
    add_foreign_key :ticketing_tickets, :ticketing_seats, column: :seat_id
    add_foreign_key :ticketing_tickets, :ticketing_event_dates, column: :date_id

    add_foreign_key :users, :members_families, column: :family_id
  end
end
