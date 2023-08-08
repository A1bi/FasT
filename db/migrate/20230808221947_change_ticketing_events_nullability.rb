# frozen_string_literal: true

class ChangeTicketingEventsNullability < ActiveRecord::Migration[7.0]
  def change
    change_table :ticketing_events, bulk: true do |t|
      t.change_null :name, false
      t.change_null :seating_id, true
      t.change_default :seating_id, from: 1, to: nil
    end
  end
end
