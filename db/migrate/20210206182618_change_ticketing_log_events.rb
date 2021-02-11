# frozen_string_literal: true

class ChangeTicketingLogEvents < ActiveRecord::Migration[6.1]
  def change
    rename_column :ticketing_log_events, :name, :action

    %i[loggable_type loggable_id action].each do |column|
      change_column_null :ticketing_log_events, column, false
    end
  end
end
