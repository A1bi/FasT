# frozen_string_literal: true

class AddReceiptTokenToBoxOfficePurchases < ActiveRecord::Migration[7.0]
  def change
    add_column :ticketing_box_office_purchases, :receipt_token, :uuid, default: 'gen_random_uuid()', null: false
    add_index :ticketing_box_office_purchases, :receipt_token
  end
end
