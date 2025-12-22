# frozen_string_literal: true

class AddCamtToTicketingBankTransactions < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        update <<-SQL.squish
          UPDATE ticketing_bank_transactions
             SET raw_source = '{"legacy_mt940_data_removed": true}'
           WHERE raw_source IS NOT NULL
        SQL
      end
      dir.down do
        # the following could not be added to change_table because t.remove does not accept an index option
        add_index :ticketing_bank_transactions, :raw_source_sha, unique: true, length: 64
      end
    end

    change_table :ticketing_bank_transactions, bulk: true do |t|
      t.rename :raw_source, :camt_source
      t.remove :raw_source_sha, type: :binary
      t.index "(camt_source->>'AcctSvcrRef')", unique: true
    end
  end
end
