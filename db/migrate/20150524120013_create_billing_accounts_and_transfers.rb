class CreateBillingAccountsAndTransfers < ActiveRecord::Migration
  def change
    create_table :ticketing_billing_accounts do |t|
      t.integer :balance, default: 0, null: false
      t.belongs_to :billable, polymorphic: true

      t.timestamps null: false
    end
    add_index :ticketing_billing_accounts, [:billable_id, :billable_type], name: :index_billing_acounts_on_id_and_type

    create_table :ticketing_billing_transfers do |t|
      t.integer :amount, default: 0, null: false
      t.belongs_to :sender, index: true
      t.belongs_to :recipient, index: true
      t.belongs_to :reverse_transfer

      t.timestamps null: false
    end
  end
end
