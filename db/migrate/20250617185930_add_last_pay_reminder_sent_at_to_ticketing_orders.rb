# frozen_string_literal: true

class AddLastPayReminderSentAtToTicketingOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :ticketing_orders, :last_pay_reminder_sent_at, :datetime
  end
end
