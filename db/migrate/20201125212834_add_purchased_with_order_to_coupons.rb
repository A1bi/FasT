# frozen_string_literal: true

class AddPurchasedWithOrderToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :ticketing_coupons, :purchased_with_order,
                   foreign_key: { to_table: :ticketing_orders }
  end
end
