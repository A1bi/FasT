class AddAffiliationToOrdersAndCoupons < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_orders, :affiliation, :string
    add_column :ticketing_coupons, :affiliation, :string
  end
end
