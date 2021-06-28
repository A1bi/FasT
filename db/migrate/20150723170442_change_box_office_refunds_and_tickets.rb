# frozen_string_literal: true

class ChangeBoxOfficeRefundsAndTickets < ActiveRecord::Migration[6.0]
  def change
    rename_table :ticketing_box_office_refunds, :ticketing_box_office_order_payments
    change_table :ticketing_tickets, bulk: true do |t|
      t.boolean :resale, default: false
      t.boolean :invalidated, default: false
    end

    reversible do |change|
      change.up do
        update 'UPDATE ticketing_box_office_order_payments SET amount = amount * -1'

        update <<-SQL.squish
          UPDATE ticketing_box_office_purchase_items
          SET purchasable_type = 'Ticketing::BoxOffice::OrderPayment'
          WHERE purchasable_type = 'Ticketing::BoxOffice::Refund'
        SQL

        update "UPDATE ticketing_tickets SET invalidated = #{quoted_true} WHERE cancellation_id IS NOT NULL"
      end

      change.down do
        update 'UPDATE ticketing_box_office_order_payments SET amount = amount * -1'

        update <<-SQL.squish
          UPDATE ticketing_box_office_purchase_items
          SET purchasable_type = 'Ticketing::BoxOffice::Refund'
          WHERE purchasable_type = 'Ticketing::BoxOffice::OrderPayment'
        SQL
      end
    end
  end
end
