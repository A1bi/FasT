class ChangeTicketingCoupons < ActiveRecord::Migration
  def up
    change_column :ticketing_coupons, :expires, :datetime
    Ticketing::Coupon.update_all(expires: DateTime.new(2013, -1, -1, -1, -1, -1))
  end
end
