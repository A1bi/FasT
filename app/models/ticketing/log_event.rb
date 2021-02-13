# frozen_string_literal: true

module Ticketing
  class LogEvent < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :loggable, polymorphic: true

    enum action: {
      created: 1,
      updated: 2,
      approved: 3,
      sent_pay_reminder: 4,
      marked_as_paid: 5,
      submitted_charge: 6,
      cancelled_tickets: 7,
      enabled_resale_for_tickets: 8,
      transferred_tickets: 9,
      updated_ticket_types: 10,
      resent_confirmation: 11,
      resent_items: 12,
      sent: 13,
      redeemed: 14
    }

    validates :action, presence: true

    def info
      super&.symbolize_keys || {}
    end
  end
end
