# frozen_string_literal: true

class CreateTicketingLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :ticketing_locations do |t|
      t.string :name, null: false
      t.string :street, null: false
      t.string :postcode, null: false
      t.string :city, null: false
      t.point :coordinates, null: false
      t.timestamps
    end

    add_belongs_to :ticketing_events, :location, foreign_key: { to_table: :ticketing_locations }

    remove_column :ticketing_events, :location, :string

    insert <<-SQL.squish
      INSERT INTO ticketing_locations
                  (name, street, postcode, city, coordinates, created_at, updated_at)
      VALUES      ('Test', 'foo', '12345', 'foo', '(123, 123)', NOW(), NOW())
    SQL

    update 'UPDATE ticketing_events SET location_id = 1'

    change_column_null :ticketing_events, :location_id, false
  end
end
