# frozen_string_literal: true

class AddAnonymizedAtToTicketingBankCharges < ActiveRecord::Migration[6.1]
  def change
    add_column :ticketing_bank_charges, :anonymized_at, :datetime
  end
end
