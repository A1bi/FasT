# frozen_string_literal: true

class CreateTicketingBankTransactionsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :ticketing_bank_transactions_orders, id: false do |t|
      t.references :bank_transaction, foreign_key: { to_table: :ticketing_bank_transactions }
      t.references :order, foreign_key: { to_table: :ticketing_orders }
      t.index %i[order_id bank_transaction_id], unique: true
    end

    reversible do |dir|
      dir.up do
        result = exec_query('SELECT id, order_id FROM ticketing_bank_transactions')
        result.each do |transaction|
          insert <<-SQL.squish
            INSERT INTO ticketing_bank_transactions_orders
                        (bank_transaction_id, order_id)
            VALUES (#{transaction['id']}, #{transaction['order_id']})
          SQL
        end
      end

      dir.down do
        result = exec_query('SELECT * FROM ticketing_bank_transactions_orders')
        result.each do |association|
          insert <<-SQL.squish
            UPDATE ticketing_bank_transactions
               SET order_id = #{association['order_id']}
             WHERE id = #{association['bank_transaction_id']}
          SQL
        end

        change_column_null :ticketing_bank_transactions, :order_id, false
      end
    end

    remove_belongs_to :ticketing_bank_transactions, :order, foreign_key: { to_table: :ticketing_orders }, null: true
  end
end
