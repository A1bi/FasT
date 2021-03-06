# frozen_string_literal: true

class CreateBillingAccountsAndTransfers < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_billing_accounts do |t|
      t.decimal :balance, default: 0, null: false
      t.belongs_to :billable, polymorphic: true, null: false, index: { name: :index_billing_acounts_on_id_and_type }

      t.timestamps null: false
    end

    create_table :ticketing_billing_transfers do |t|
      t.decimal :amount, default: 0, null: false
      t.string :note_key
      t.belongs_to :account, index: true, null: false
      t.belongs_to :participant, index: true
      t.belongs_to :reverse_transfer

      t.timestamps null: false
    end

    remove_reference :ticketing_orders, :cancellation

    remove_column :ticketing_tickets, :paid, :boolean
  end

  def migrate(direction)
    super

    type = direction == :up ? :decimal : :float
    {
      bank_charges: :amount,
      ticket_types: :price,
      tickets: :price,
      orders: :total
    }.each do |table, column|
      change_column "ticketing_#{table}", column, type,
                    default: 0, null: false
    end
  end
end
