class CreateTicketsTicketTypes < ActiveRecord::Migration
  def change
    create_table :tickets_ticket_types do |t|
      t.string :name
      t.float :price

      t.timestamps
    end
  end
end
