# frozen_string_literal: true

class AddArchivedToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :archived, :boolean, default: false

    reversible do |dir|
      dir.up do
        Ticketing::Event.update_all(archived: true)
      end
    end
  end
end
