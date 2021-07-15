# frozen_string_literal: true

class RemoveCovid19PresenceTracing < ActiveRecord::Migration[6.1]
  def change
    remove_column :ticketing_events, :covid19_presence_tracing, :boolean, null: false, default: false
  end
end
