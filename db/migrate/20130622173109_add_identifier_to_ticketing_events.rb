class AddIdentifierToTicketingEvents < ActiveRecord::Migration
  def change
    add_column :ticketing_events, :identifier, :string
  end
end
