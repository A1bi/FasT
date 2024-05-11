# frozen_string_literal: true

class AddEbicsSourceToTicketingBankTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :ticketing_bank_transactions, :raw_source, :jsonb
  end
end
