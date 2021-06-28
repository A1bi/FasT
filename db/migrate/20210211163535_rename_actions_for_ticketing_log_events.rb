# frozen_string_literal: true

class RenameActionsForTicketingLogEvents < ActiveRecord::Migration[6.1]
  def up
    actions = {
      edited: :updated,
      charge_submitted: :submitted_charge,
      tickets_cancelled: :cancelled_tickets,
      tickets_transferred: :transferred_tickets,
      ticket_types_edited: :updated_ticket_types,
      resent_tickets: :resent_items
    }
    actions.each do |old, new|
      update "UPDATE ticketing_log_events SET action = '#{new}' WHERE action = '#{old}'"
    end
  end
end
