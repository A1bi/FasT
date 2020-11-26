# frozen_string_literal: true

class AddAmountToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_coupons, :amount, :decimal, null: false, default: 0
  end
end
