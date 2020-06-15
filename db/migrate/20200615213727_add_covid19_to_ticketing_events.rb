# frozen_string_literal: true

class AddCovid19ToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :covid19, :boolean,
               null: false, default: false
  end
end
