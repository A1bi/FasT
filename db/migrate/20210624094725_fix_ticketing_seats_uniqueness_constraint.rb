# frozen_string_literal: true

class FixTicketingSeatsUniquenessConstraint < ActiveRecord::Migration[6.1]
  def change
    # seat number uniqueness checks should be deferred to when the transaction is comitted
    # case example: a seat in the middle is removed, so the number of all following seats need to be decreased by one
    # this would result in a failing uniqueness check when updating the seats, because for a brief moment a seat would
    # have the same number as its following one, so we need to defer this check

    remove_index :ticketing_seats, %i[block_id number], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          ALTER TABLE ticketing_seats
          ADD CONSTRAINT ticketing_seats_number_uniqueness
          UNIQUE (block_id, number)
          INITIALLY DEFERRED
        SQL
      end
      dir.down do
        execute <<-SQL.squish
          ALTER TABLE ticketing_seats
          DROP CONSTRAINT ticketing_seats_number_uniqueness
        SQL
      end
    end
  end
end
