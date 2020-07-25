# frozen_string_literal: true

class AddEventLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :location, :string
  end
end
