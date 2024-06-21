# frozen_string_literal: true

class CreateTicketingStripeTransactions < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        execute "ALTER TYPE ticketing_pay_method ADD VALUE 'stripe';"

        execute <<-SQL.squish
          CREATE TYPE ticketing_stripe_transaction_type
              AS ENUM ('payment_intent', 'refund');
          CREATE TYPE ticketing_stripe_payment_method
              AS ENUM ('apple_pay', 'google_pay');
        SQL
      end

      dir.down do
        execute <<-SQL.squish
          DROP TYPE ticketing_stripe_transaction_type;
          DROP TYPE ticketing_stripe_payment_method;
        SQL
      end
    end

    create_table :ticketing_stripe_transactions do |t|
      t.belongs_to :order, foreign_key: { to_table: :ticketing_orders }
      t.column :type, :ticketing_stripe_transaction_type, null: false
      t.string :stripe_id, null: false
      t.decimal :amount, null: false
      t.column :method, :ticketing_stripe_payment_method
      t.timestamps
    end
  end
end
