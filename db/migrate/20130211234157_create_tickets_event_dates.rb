# frozen_string_literal: true

class CreateTicketsEventDates < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_event_dates do |t|
      t.datetime :date
      t.integer :event_id

      t.timestamps
    end
  end
end
