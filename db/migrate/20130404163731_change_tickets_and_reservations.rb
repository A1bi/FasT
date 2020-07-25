# frozen_string_literal: true

class ChangeTicketsAndReservations < ActiveRecord::Migration[6.0]
  def change
    change_table :tickets_tickets, bulk: true do |t|
      t.integer :seat_id
      t.integer :date_id
    end
    remove_column :tickets_tickets, :reservation_id, :integer
  end
end
