# frozen_string_literal: true

class MoveTicketingCouponFreeTicketsToBillingAccount < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute "CREATE TYPE coupon_value_type AS ENUM ('free_tickets', 'credit')"
      end

      dir.down do
        execute 'DROP TYPE coupon_value_type'
      end
    end

    add_column :ticketing_coupons, :value_type, :coupon_value_type

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE ticketing_coupons AS c
          SET value_type = 'credit'
          FROM ticketing_billing_accounts AS ba
          WHERE ba.billable_type = 'Ticketing::Coupon'
          AND ba.billable_id = c.id
          AND ba.id IS NOT NULL
        SQL

        execute <<-SQL.squish
          UPDATE ticketing_coupons
          SET value_type = 'free_tickets'
          WHERE value_type IS NULL
        SQL
      end
    end

    change_column_null :ticketing_coupons, :value_type, false
    remove_column :ticketing_coupons, :free_tickets, :integer, default: 0
  end
end
