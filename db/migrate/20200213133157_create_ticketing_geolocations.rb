# frozen_string_literal: true

class CreateTicketingGeolocations < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_geolocations do |t|
      t.point :coordinates, null: false
      t.string :postcode, null: false, index: true
      t.string :cities, array: true, null: false, default: '{}'
      t.string :districts, array: true, null: false, default: '{}'

      t.timestamps
    end
  end
end
