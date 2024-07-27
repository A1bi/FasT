# frozen_string_literal: true

class AddExceptionallyCustomerCancellableToTicketingTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :ticketing_tickets, :exceptionally_customer_cancellable, :boolean, null: false, default: false
  end
end
