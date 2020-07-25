# frozen_string_literal: true

class RemoveBicFromTicketingBankCharges < ActiveRecord::Migration[6.0]
  def up
    remove_column :ticketing_bank_charges, :bic
  end

  def down
    add_column :ticketing_bank_charges, :bic, :string
  end
end
