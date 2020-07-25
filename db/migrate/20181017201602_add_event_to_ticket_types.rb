# frozen_string_literal: true

class AddEventToTicketTypes < ActiveRecord::Migration[6.0]
  def change
    add_reference :ticketing_ticket_types, :event
  end
end
