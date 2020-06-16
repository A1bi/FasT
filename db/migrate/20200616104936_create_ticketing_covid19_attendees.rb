# frozen_string_literal: true

class CreateTicketingCovid19Attendees < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_covid19_attendees do |t|
      t.belongs_to :ticket,
                   null: false, foreign_key: { to_table: :ticketing_tickets }
      t.string :name, null: false
      t.string :street, null: false
      t.string :plz, null: false
      t.string :city, null: false
      t.string :phone, null: false
      t.timestamps
    end
  end
end
