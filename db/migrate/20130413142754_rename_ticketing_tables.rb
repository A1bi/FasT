class RenameTicketingTables < ActiveRecord::Migration
  def change
    %w(bank_charges blocks bunches cancellations event_dates events log_events orders reservations seats ticket_types tickets).each do |table|
      rename_table "tickets_#{table}", "ticketing_#{table}"
    end
  end
end
