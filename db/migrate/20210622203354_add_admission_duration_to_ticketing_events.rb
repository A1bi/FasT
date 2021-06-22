# frozen_string_literal: true

class AddAdmissionDurationToTicketingEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :ticketing_events, :admission_duration, :integer
    reversible do |dir|
      dir.up { update 'UPDATE ticketing_events SET admission_duration = 60' }
    end
    change_column_null :ticketing_events, :admission_duration, false
  end
end
