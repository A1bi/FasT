# frozen_string_literal: true

class RenameTicketingBillingTransfers < ActiveRecord::Migration[6.1]
  def change
    rename_table :ticketing_billing_transfers, :ticketing_billing_transactions
    rename_column :ticketing_billing_transactions,
                  :reverse_transfer_id, :reverse_transaction_id
  end
end
