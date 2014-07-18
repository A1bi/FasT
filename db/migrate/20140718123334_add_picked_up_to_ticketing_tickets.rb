class AddPickedUpToTicketingTickets < ActiveRecord::Migration
  def change
    add_column :ticketing_tickets, :picked_up, :boolean, default: false
  end
end
