# frozen_string_literal: true

class AddCovid19PresenceTracing < ActiveRecord::Migration[6.1]
  def change
    add_column :ticketing_events, :covid19_presence_tracing, :boolean, null: false, default: false
    add_column :ticketing_event_dates, :covid19_check_in_url, :string
  end
end
