class AddExclusiveToTicketingTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticketing_ticket_types, :exclusive, :boolean, default: false
  end
end
