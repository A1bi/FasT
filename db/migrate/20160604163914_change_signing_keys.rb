class ChangeSigningKeys < ActiveRecord::Migration
  def change
    rename_table :ticketing_ticket_signing_keys, :ticketing_signing_keys
    remove_column :ticketing_tickets, :signing_key_id, :integer
  end
end
