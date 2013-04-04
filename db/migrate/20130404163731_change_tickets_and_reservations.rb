class ChangeTicketsAndReservations < ActiveRecord::Migration
  def change
    add_column :tickets_tickets, :seat_id, :integer
    add_column :tickets_tickets, :date_id, :integer
    remove_column :tickets_tickets, :reservation_id
  end
end
