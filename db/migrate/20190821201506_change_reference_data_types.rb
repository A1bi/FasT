class ChangeReferenceDataTypes < ActiveRecord::Migration[5.2]
  def up
    {
      active_storage_attachments: %i[blob_id record_id],
      members_exclusive_ticket_type_credit_spendings: %i[member_id ticket_type_id order_id],
      members_exclusive_ticket_type_credits: %i[ticket_type_id],
      newsletter_images: %i[newsletter_id],
      newsletter_newsletters_subscriber_lists: %i[newsletter_id subscriber_list_id],
      newsletter_subscribers: %i[subscriber_list_id],
      passbook_passes: %i[assignable_id],
      passbook_registrations: %i[pass_id device_id],
      photos: %i[gallery_id],
      ticketing_bank_charges: %i[submission_id chargeable_id],
      ticketing_billing_accounts: %i[billable_id],
      ticketing_billing_transfers: %i[account_id participant_id reverse_transfer_id],
      ticketing_blocks: %i[seating_id],
      ticketing_box_office_order_payments: %i[order_id],
      ticketing_box_office_purchase_items: %i[purchase_id purchasable_id],
      ticketing_box_office_purchases: %i[box_office_id],
      ticketing_check_ins: %i[ticket_id checkpoint_id],
      ticketing_coupon_redemptions: %i[coupon_id order_id],
      ticketing_coupons_reservation_groups: %i[coupon_id reservation_group_id],
      ticketing_event_dates: %i[event_id],
      ticketing_events: %i[seating_id],
      ticketing_log_events: %i[user_id loggable_id],
      ticketing_orders: %i[store_id box_office_id date_id],
      ticketing_reservations: %i[date_id seat_id group_id],
      ticketing_seats: %i[block_id],
      ticketing_ticket_types: %i[event_id],
      ticketing_tickets: %i[order_id cancellation_id type_id seat_id date_id],
      users: %i[family_id]
    }.each do |table, columns|
      columns.each do |column|
        change_column table, column, :bigint
      end
    end
  end
end
