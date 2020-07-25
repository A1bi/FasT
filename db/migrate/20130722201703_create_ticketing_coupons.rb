# frozen_string_literal: true

class CreateTicketingCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_coupons do |t|
      t.string :code
      t.string :expires
      t.string :recipient

      t.timestamps
    end

    create_table :ticketing_coupons_reservation_groups, id: false do |t|
      t.integer :coupon_id
      t.integer :reservation_group_id
      t.timestamps
    end

    create_table :ticketing_coupon_ticket_type_assignments do |t|
      t.integer :coupon_id
      t.integer :ticket_type_id
      t.integer :number

      t.timestamps
    end

    add_column :ticketing_bunches, :coupon_id, :integer
  end
end
