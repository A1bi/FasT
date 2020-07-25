# frozen_string_literal: true

class AddSubtitleToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :subtitle, :string
  end
end
