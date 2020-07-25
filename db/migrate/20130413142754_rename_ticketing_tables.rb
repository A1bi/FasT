# frozen_string_literal: true

class RenameTicketingTables < ActiveRecord::Migration[6.0]
  def change
    %i[bank_charges blocks bunches cancellations event_dates events log_events
       orders reservations seats ticket_types tickets].each do |table|
      rename_table "tickets_#{table}", "ticketing_#{table}"
    end
  end
end
