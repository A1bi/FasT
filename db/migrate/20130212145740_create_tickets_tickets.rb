class CreateTicketsTickets < ActiveRecord::Migration
  def change
    create_table :tickets_tickets do |t|
      t.integer :number
			t.float :price
      t.integer :bunch_id
      t.integer :cancellation_id
      t.integer :type_id
			t.integer :reservation_id

      t.timestamps
    end
  end
end
