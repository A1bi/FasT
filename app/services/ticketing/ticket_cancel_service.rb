# frozen_string_literal: true

module Ticketing
  class TicketCancelService < TicketBaseService
    def initialize(tickets, reason:, current_user: nil)
      super(tickets, current_user: current_user)
      @reason = reason
    end

    def execute(send_customer_email: true)
      cancellation = Cancellation.create(reason: @reason)

      valid_tickets_by_order.each do |order, tickets|
        update_order_balance(order) do
          cancellation.tickets += tickets
        end

        log_cancellation(order, tickets)
        send_email(order) if send_customer_email
      end

      update_node_with_tickets(@tickets)
    end

    private

    def update_order_balance(order, &block)
      OrderBillingService.new(order).update_balance(:cancellation, &block)
    end

    def log_cancellation(order, tickets)
      log_service(order).cancel_tickets(tickets, reason: @reason)
    end

    def send_email(order)
      OrderMailer.with(order: order, reason: @reason.to_s)
                 .cancellation.deliver_later
    end
  end
end
