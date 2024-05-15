# frozen_string_literal: true

class AddEbicsResponseToTicketingBankSubmissions < ActiveRecord::Migration[7.1]
  def change
    add_column :ticketing_bank_submissions, :ebics_response, :jsonb
  end
end
