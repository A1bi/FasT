class CreateTicketsReservations < ActiveRecord::Migration
  def change
    create_table :tickets_reservations do |t|
      t.datetime :expires
      t.integer :date_id
      t.integer :seat_id

      t.timestamps
    end
  end
end
