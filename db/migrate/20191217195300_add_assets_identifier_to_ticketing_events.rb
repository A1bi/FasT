class AddAssetsIdentifierToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :assets_identifier, :string

    reversible do |dir|
      dir.up do
        execute 'UPDATE ticketing_events SET assets_identifier = identifier'
      end
    end

    change_column_null :ticketing_events, :identifier, false
    change_column_null :ticketing_events, :assets_identifier, false
    change_column_null :ticketing_events, :slug, false

    remove_index :ticketing_events, :identifier
    remove_index :ticketing_events, :slug

    add_index :ticketing_events, :identifier, unique: true
    add_index :ticketing_events, :slug, unique: true
  end
end
