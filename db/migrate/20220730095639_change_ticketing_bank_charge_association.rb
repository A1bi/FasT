# frozen_string_literal: true

class ChangeTicketingBankChargeAssociation < ActiveRecord::Migration[7.0]
  def change
    remove_column :ticketing_bank_charges, :chargeable_type, :string
    rename_column :ticketing_bank_charges, :chargeable_id, :order_id
    add_index :ticketing_bank_charges, :order_id
    add_foreign_key :ticketing_bank_charges, :ticketing_orders, column: :order_id
  end
end
