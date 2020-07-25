# frozen_string_literal: true

class AddPickedUpToTicketingTickets < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_tickets, :picked_up, :boolean, default: false
  end
end
