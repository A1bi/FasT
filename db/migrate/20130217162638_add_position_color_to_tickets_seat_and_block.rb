# frozen_string_literal: true

class AddPositionColorToTicketsSeatAndBlock < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets_blocks, :color, :string, default: 'black'
    change_table :tickets_seats, bulk: true do |t|
      t.float :position_x, default: 0
      t.float :position_y, default: 0
    end
  end
end
