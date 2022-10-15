# frozen_string_literal: true

class AdjustTicketingLogEventActions < ActiveRecord::Migration[7.0]
  def up
    update <<-SQL.squish
      UPDATE ticketing_log_events
         SET action = 15,
             info = info - 'reason'
       WHERE action = 7
         AND info->'reason' IN ('"cancelled_by_customer"', '"date_cancelled"')
    SQL

    update <<-SQL.squish
      UPDATE ticketing_log_events
         SET action = 16,
             info = info - 'reason'
       WHERE action = 7
         AND info->'reason' = '"cancellation_at_box_office"'
    SQL

    update <<-SQL.squish
      UPDATE ticketing_log_events
         SET action = 17,
             info = info - 'reason'
       WHERE action = 7
         AND info->'reason' IN (NULL, 'null', '""')
    SQL
  end
end
