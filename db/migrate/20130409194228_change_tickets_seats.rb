# frozen_string_literal: true

class ChangeTicketsSeats < ActiveRecord::Migration[6.0]
  def up
    change_table :tickets_seats, bulk: true do |t|
      t.change :position_x, :integer
      t.change :position_y, :integer
    end
  end

  def down
    change_table :tickets_seats, bulk: true do |t|
      t.change :position_x, :float
      t.change :position_y, :float
    end
  end
end
