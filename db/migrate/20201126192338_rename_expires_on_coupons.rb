# frozen_string_literal: true

class RenameExpiresOnCoupons < ActiveRecord::Migration[6.0]
  def change
    rename_column :ticketing_coupons, :expires, :expires_at
  end
end
