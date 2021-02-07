# frozen_string_literal: true

module Ticketing
  class TicketCancelService < TicketBaseService
    def initialize(tickets, reason:, current_user: nil)
      super(tickets, current_user: current_user)
      @reason = reason
    end

    def execute(send_customer_email: true)
      ActiveRecord::Base.transaction do
        valid_tickets.inject(nil) do |cancellation, ticket|
          ticket.cancel(cancellation || @reason)
        end

        valid_tickets_by_order.each do |order, tickets|
          next unless update_order(order, tickets)

          send_email(order) if send_customer_email
        end

        update_node_with_tickets(@tickets)
      end

      # return copy so a count wouldn't reload and thus make it empty
      valid_tickets.to_a
    end

    private

    def update_order(order, tickets)
      order.update_total_and_billing(:cancellation)
      return unless order.save

      log_service(order).cancel_tickets(tickets, reason: @reason)
    end

    def send_email(order)
      Ticketing::OrderMailer.with(order: order, reason: @reason.to_s)
                            .cancellation.deliver_later
    end
  end
end
