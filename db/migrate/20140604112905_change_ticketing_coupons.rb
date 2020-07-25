# frozen_string_literal: true

class ChangeTicketingCoupons < ActiveRecord::Migration[6.0]
  def up
    change_column :ticketing_coupons, :expires, :datetime, using: 'expires::timestamp'
  end
end
