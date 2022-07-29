# frozen_string_literal: true

class CreateTicketingBankRefunds < ActiveRecord::Migration[7.0]
  def change
    create_table :ticketing_bank_refund_submissions do |t| # rubocop:disable Style/SymbolProc
      t.timestamps
    end

    create_table :ticketing_bank_refunds do |t|
      t.string :name
      t.string :iban
      t.decimal :amount, default: 0, null: false
      t.belongs_to :order, foreign_key: { to_table: :ticketing_orders }
      t.belongs_to :submission, foreign_key: { to_table: :ticketing_bank_refund_submissions }
      t.datetime :anonymized_at
      t.timestamps
    end
  end
end
