class AddEventToTicketTypes < ActiveRecord::Migration[5.2]
  def change
    add_reference :ticketing_ticket_types, :event
  end
end
