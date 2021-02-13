# frozen_string_literal: true

class ChangeTicketingLogEventsActionToEnum < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL.squish
      ALTER TABLE ticketing_log_events
        ALTER COLUMN action TYPE INTEGER
        USING CASE action
          WHEN 'created' THEN 1
          WHEN 'updated' THEN 2
          WHEN 'approved' THEN 3
          WHEN 'sent_pay_reminder' THEN 4
          WHEN 'marked_as_paid' THEN 5
          WHEN 'submitted_charge' THEN 6
          WHEN 'cancelled_tickets' THEN 7
          WHEN 'enabled_resale_for_tickets' THEN 8
          WHEN 'transferred_tickets' THEN 9
          WHEN 'updated_ticket_types' THEN 10
          WHEN 'resent_confirmation' THEN 11
          WHEN 'resent_items' THEN 12
          WHEN 'sent' THEN 13
          WHEN 'redeemed' THEN 14
        END;
    SQL
  end

  def down
    execute 'DELETE FROM ticketing_log_events'
    change_column :ticketing_log_events, :action, :string
  end
end
