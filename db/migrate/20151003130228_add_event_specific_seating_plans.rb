# frozen_string_literal: true

class AddEventSpecificSeatingPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_seatings do |t|
      t.integer :number_of_seats, default: 0
      t.timestamps
    end
    add_reference :ticketing_blocks, :seating, null: false, default: 1
    add_reference :ticketing_events, :seating, null: false, default: 1
  end
end
