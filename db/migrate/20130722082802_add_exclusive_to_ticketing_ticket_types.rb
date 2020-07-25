# frozen_string_literal: true

class AddExclusiveToTicketingTicketTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_ticket_types, :exclusive, :boolean, default: false
  end
end
