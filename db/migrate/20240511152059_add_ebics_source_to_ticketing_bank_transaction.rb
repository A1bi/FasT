# frozen_string_literal: true

class AddEbicsSourceToTicketingBankTransaction < ActiveRecord::Migration[7.1]
  def change
    change_table :ticketing_bank_transactions do |t|
      t.jsonb :raw_source
      t.binary :raw_source_sha
      t.index :raw_source_sha, length: 64, unique: true
    end
  end
end
