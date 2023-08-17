# frozen_string_literal: true

class RemoveCovid19 < ActiveRecord::Migration[7.0]
  def change
    remove_column :ticketing_event_dates, :covid19_check_in_url, :string
    remove_column :ticketing_events, :covid19, :boolean, null: false, default: false
  end
end
