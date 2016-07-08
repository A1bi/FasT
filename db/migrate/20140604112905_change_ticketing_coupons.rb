class ChangeTicketingCoupons < ActiveRecord::Migration
  def up
    change_column :ticketing_coupons, :expires, :datetime
  end
end
