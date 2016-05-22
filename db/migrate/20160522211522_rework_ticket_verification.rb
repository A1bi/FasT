class ReworkTicketVerification < ActiveRecord::Migration
  def change
    create_table :ticketing_ticket_signing_keys do |t|
      t.string :secret, null: false, default: "", limit: 32
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    change_table :ticketing_tickets do |t|
      t.belongs_to :signing_key
    end
  end
end
