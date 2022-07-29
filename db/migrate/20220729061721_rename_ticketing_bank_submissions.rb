# frozen_string_literal: true

class RenameTicketingBankSubmissions < ActiveRecord::Migration[7.0]
  def change
    rename_table :ticketing_bank_submissions, :ticketing_bank_charge_submissions
  end
end
