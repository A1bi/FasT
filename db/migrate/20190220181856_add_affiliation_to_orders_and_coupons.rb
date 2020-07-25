# frozen_string_literal: true

class AddAffiliationToOrdersAndCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_orders, :affiliation, :string
    add_column :ticketing_coupons, :affiliation, :string
  end
end
