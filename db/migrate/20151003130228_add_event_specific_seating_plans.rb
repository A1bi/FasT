class AddEventSpecificSeatingPlans < ActiveRecord::Migration
  def change
    create_table :ticketing_seatings do |t|
      t.integer :number_of_seats, default: 0
      t.timestamps
    end
    add_reference :ticketing_blocks, :seating, null: false, default: 1
    add_reference :ticketing_events, :seating, null: false, default: 1

    reversible do |change|
      change.up do
        execute "INSERT INTO ticketing_seatings () VALUES()"
      end
    end
  end
end
