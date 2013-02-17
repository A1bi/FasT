class AddPositionColorToTicketsSeatAndBlock < ActiveRecord::Migration
  def change
    add_column :tickets_blocks, :color, :string, :default => "black"
    add_column :tickets_seats, :position_x, :float, :default => 0
    add_column :tickets_seats, :position_y, :float, :default => 0
  end
end
