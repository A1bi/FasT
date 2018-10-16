class AddArchivedToTicketingEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_events, :archived, :boolean, default: false

    reversible do |dir|
      dir.up do
        Ticketing::Event.update_all(archived: true) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
