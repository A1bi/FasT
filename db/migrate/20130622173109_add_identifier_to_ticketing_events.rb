class AddIdentifierToTicketingEvents < ActiveRecord::Migration
  def change
    add_column :ticketing_events, :identifier, :string
  end
  
  def migrate(direction)
    super

    if direction == :up
      Ticketing::Event.first.update_attribute(:identifier, "jedermann") if Ticketing::Event.first
    end
  end
end
