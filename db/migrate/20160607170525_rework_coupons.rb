# frozen_string_literal: true

class ReworkCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_coupons, :free_tickets, :integer, default: 0

    reversible do |change|
      change.up do
        drop_table :ticketing_coupon_ticket_type_assignments
      end

      change.down do
        create_table :ticketing_coupon_ticket_type_assignments do |t|
          t.integer  :coupon_id
          t.integer  :ticket_type_id
          t.integer  :number
          t.timestamps
        end
      end
    end
  end
end
