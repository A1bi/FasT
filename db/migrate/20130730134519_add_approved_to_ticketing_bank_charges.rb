# frozen_string_literal: true

class AddApprovedToTicketingBankCharges < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_bank_charges, :approved, :boolean, default: false
  end
end
