# frozen_string_literal: true

class AddPaidToTicketingTickets < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_tickets, :paid, :boolean, default: false
  end

  def migrate(direction)
    super
    change_column :members_dates, :info, :text, limit: nil if direction == :up
  end
end
