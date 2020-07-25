# frozen_string_literal: true

class ChangeSeatReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_reservation_groups do |t|
      t.string :name

      t.timestamps
    end

    add_column :ticketing_reservations, :group_id, :integer
  end
end
