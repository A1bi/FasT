# frozen_string_literal: true

class AddInfoToTicketsTicketType < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets_ticket_types, :info, :string
  end
end
