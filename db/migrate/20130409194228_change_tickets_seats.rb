class ChangeTicketsSeats < ActiveRecord::Migration
  def change
    change_column :tickets_seats, :position_x, :integer
    change_column :tickets_seats, :position_y, :integer
  end
end
