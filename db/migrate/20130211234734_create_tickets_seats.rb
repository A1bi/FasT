# frozen_string_literal: true

class CreateTicketsSeats < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_seats do |t|
      t.integer :number
      t.integer :row
      t.integer :block_id

      t.timestamps
    end
  end
end
