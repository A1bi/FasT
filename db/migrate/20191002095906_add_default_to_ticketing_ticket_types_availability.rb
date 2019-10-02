class AddDefaultToTicketingTicketTypesAvailability < ActiveRecord::Migration[6.0]
  def change
    change_column_default :ticketing_ticket_types, :availability,
                          from: nil, to: :universal
  end
end
