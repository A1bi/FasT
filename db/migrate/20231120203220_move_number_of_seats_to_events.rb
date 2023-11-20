# frozen_string_literal: true

class MoveNumberOfSeatsToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :ticketing_events, :number_of_seats, :integer

    reversible do |dir|
      dir.up do
        update <<-SQL.squish
          UPDATE ticketing_events
             SET number_of_seats = s.number_of_seats,
                 seating_id = NULL
            FROM ticketing_seatings s
           WHERE seating_id = s.id
             AND s.number_of_seats > 0
        SQL

        delete <<-SQL.squish
          DELETE FROM ticketing_seatings
                WHERE number_of_seats > 0
        SQL
      end
    end

    remove_column :ticketing_seatings, :number_of_seats, :integer, default: 0
  end
end
