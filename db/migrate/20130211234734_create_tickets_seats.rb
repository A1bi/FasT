class CreateTicketsSeats < ActiveRecord::Migration
  def change
    create_table :tickets_seats do |t|
      t.integer :number
      t.integer :row
      t.integer :block_id

      t.timestamps
    end
  end
end
