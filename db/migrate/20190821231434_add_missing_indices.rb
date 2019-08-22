class AddMissingIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :documents, :members_group

    add_index :newsletter_subscribers, :email, unique: true
    add_index :newsletter_subscribers, :token, unique: true

    add_index :passbook_passes, %i[type_id serial_number], unique: true
    add_index :passbook_passes, %i[assignable_id assignable_type]

    add_index :passbook_registrations, :pass_id
    add_index :passbook_registrations, :device_id

    add_index :photos, :gallery_id

    add_index :ticketing_bank_charges, %i[chargeable_id chargeable_type], name: :index_ticketing_bank_charges_on_chargeable
    add_index :ticketing_bank_charges, :approved
    add_index :ticketing_bank_charges, :submission_id

    add_index :ticketing_blocks, :seating_id

    add_index :ticketing_box_office_purchase_items, :purchase_id
    add_index :ticketing_box_office_purchase_items, %i[purchasable_id purchasable_type], name: :index_ticketing_box_office_purchase_items_on_purchasable

    add_index :ticketing_box_office_purchases, :box_office_id

    add_index :ticketing_check_ins, :ticket_id
    add_index :ticketing_check_ins, :checkpoint_id
    add_index :ticketing_check_ins, :medium

    add_index :ticketing_coupon_redemptions, :coupon_id
    add_index :ticketing_coupon_redemptions, :order_id

    add_index :ticketing_coupons_reservation_groups, :coupon_id
    add_index :ticketing_coupons_reservation_groups, :reservation_group_id, name: :index_ticketing_coupons_reservation_groups_on_group_id

    add_index :ticketing_event_dates, :event_id

    add_index :ticketing_events, :seating_id
    add_index :ticketing_events, :archived

    add_index :ticketing_log_events, :user_id
    add_index :ticketing_log_events, %i[loggable_id loggable_type]

    add_index :ticketing_orders, :number, unique: true
    add_index :ticketing_orders, :paid
    add_index :ticketing_orders, :store_id
    add_index :ticketing_orders, :type
    add_index :ticketing_orders, :box_office_id

    add_index :ticketing_push_notifications_devices, %i[app token], unique: true

    add_index :ticketing_reservations, %i[date_id seat_id group_id], unique: true, name: :index_ticketing_reservations_on_date_seat_group_id
    add_index :ticketing_reservations, %i[date_id seat_id]
    add_index :ticketing_reservations, :date_id
    add_index :ticketing_reservations, :seat_id
    add_index :ticketing_reservations, :group_id

    add_index :ticketing_seats, %i[block_id number], unique: true
    add_index :ticketing_seats, :block_id

    add_index :ticketing_signing_keys, :active

    add_index :ticketing_ticket_types, :exclusive
    add_index :ticketing_ticket_types, %i[exclusive event_id]

    add_index :ticketing_tickets, :order_id
    add_index :ticketing_tickets, :type_id
    add_index :ticketing_tickets, %i[seat_id date_id]
    add_index :ticketing_tickets, %i[seat_id date_id], unique: true, where: 'NOT invalidated', name: :index_ticketing_tickets_on_seat_id_and_date_id_unique
    add_index :ticketing_tickets, :seat_id
    add_index :ticketing_tickets, :date_id

    add_index :users, :email, unique: true
    add_index :users, :activation_code, unique: true
    add_index :users, :type
  end
end
