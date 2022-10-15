# frozen_string_literal: true

module Ticketing
  class LogEventCreateService
    def initialize(loggable, current_user: nil)
      @loggable = loggable
      @current_user = current_user
    end

    def create
      create_event(:created)
    end

    def update
      create_event(:updated)
    end

    def mark_as_paid
      create_event(:marked_as_paid)
    end

    def redeem
      create_event(:redeemed)
    end

    def send(email:, recipient:)
      create_event(:sent, email:, recipient:)
    end

    def resend_confirmation
      create_event(:resent_confirmation) if web_order?
    end

    def resend_items
      create_event(:resent_items) if web_order?
    end

    def send_pay_reminder
      create_event(:sent_pay_reminder) if web_order?
    end

    def update_ticket_types(tickets)
      create_event_with_tickets(:updated_ticket_types, tickets)
    end

    def cancel_tickets(tickets, reason: nil)
      info = {}
      action = if reason == :box_office
                 :cancelled_tickets_at_box_office
               elsif reason == :self_service
                 :cancelled_tickets_by_customer
               elsif reason.blank?
                 :cancelled_tickets_without_reason
               else
                 info = { reason: }
                 :cancelled_tickets
               end
      create_event_with_tickets(action, tickets, info)
    end

    def transfer_tickets(tickets, by_customer: false)
      create_event_with_tickets(by_customer ? :transferred_tickets_by_customer : :transferred_tickets, tickets)
    end

    def enable_resale_for_tickets(tickets)
      create_event_with_tickets(:enabled_resale_for_tickets, tickets)
    end

    private

    def create_event(action, info = {})
      event = @loggable.log_events.new(action:, user: @current_user, info:)
      event.save if @loggable.persisted?
    end

    def create_event_with_tickets(action, tickets, info = {})
      return if tickets.none?

      info[:count] = tickets.size
      create_event(action, info)
    end

    def web_order?
      @loggable.is_a? Web::Order
    end
  end
end
