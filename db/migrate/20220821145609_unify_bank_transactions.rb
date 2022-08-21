# frozen_string_literal: true

class UnifyBankTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_table :ticketing_bank_charges, :ticketing_bank_transactions
    rename_table :ticketing_bank_charge_submissions, :ticketing_bank_submissions

    reversible do |dir|
      dir.up do
        remove_foreign_key :ticketing_bank_refunds, to_table: :ticketing_bank_refund_submissions

        result = exec_query('SELECT * FROM ticketing_bank_refund_submissions')
        result.each do |submission|
          new_id = insert <<-SQL.squish
            INSERT INTO ticketing_bank_submissions
                        (created_at, updated_at)
            VALUES ('#{submission['created_at']}', '#{submission['updated_at']}')
          SQL

          update <<-SQL.squish
            UPDATE ticketing_bank_refunds
               SET submission_id = #{new_id}
             WHERE submission_id = #{submission['id']}
          SQL
        end

        result = exec_query('SELECT * FROM ticketing_bank_refunds')
        result.each do |refund|
          insert <<-SQL.squish
            INSERT INTO ticketing_bank_transactions
                        (name, iban, amount, order_id, submission_id, created_at, updated_at)
            VALUES ('#{refund['name']}', '#{refund['iban']}', #{-refund['amount']},
                    #{refund['order_id']}, #{refund['submission_id'] || 'NULL'},
                    '#{refund['created_at']}', '#{refund['updated_at']}')
          SQL
        end
      end
    end

    drop_table :ticketing_bank_refunds do |t|
      t.string :name
      t.string :iban
      t.decimal :amount, default: 0, null: false
      t.belongs_to :order, foreign_key: { to_table: :ticketing_orders }
      t.belongs_to :submission, foreign_key: { to_table: :ticketing_bank_refund_submissions }
      t.datetime :anonymized_at
      t.timestamps
    end

    drop_table :ticketing_bank_refund_submissions do |t| # rubocop:disable Style/SymbolProc
      t.timestamps
    end
  end
end
