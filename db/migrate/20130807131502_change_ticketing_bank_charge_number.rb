# frozen_string_literal: true

class ChangeTicketingBankChargeNumber < ActiveRecord::Migration[6.0]
  def up
    change_column :ticketing_bank_charges, :number, :integer, limit: 8
  end
end
