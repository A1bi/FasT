# frozen_string_literal: true

class AddIdentifierToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :identifier, :string
  end
end
