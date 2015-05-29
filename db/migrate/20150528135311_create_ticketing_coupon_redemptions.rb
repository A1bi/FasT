class CreateTicketingCouponRedemptions < ActiveRecord::Migration
  def change
    create_table :ticketing_coupon_redemptions do |t|
      t.belongs_to :coupon, null: false
      t.belongs_to :order, null: false

      t.timestamps null: false
    end
    
    remove_reference :ticketing_orders, :coupon, index: true
  end
end
