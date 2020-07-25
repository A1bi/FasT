# frozen_string_literal: true

class CreateTicketsReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_reservations do |t|
      t.datetime :expires
      t.integer :date_id
      t.integer :seat_id

      t.timestamps
    end
  end
end
