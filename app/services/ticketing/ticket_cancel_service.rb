# frozen_string_literal: true

module Ticketing
  class TicketCancelService < TicketBaseService
    def initialize(tickets, reason: nil, current_user: nil)
      super(tickets, current_user:)
      @reason = reason
    end

    def execute(refund: nil, send_customer_email: true)
      return if uncancelled_tickets.none?

      update_order_balance(:cancellation) do
        @cancellation = Cancellation.create(
          reason: @reason,
          tickets: uncancelled_tickets
        )
        order.tickets.reload
      end

      log_cancellation
      # .nil? is important, refund can be {} (for Stripe) which .present? will return false for
      transaction = refund_order(refund) unless refund.nil?
      send_email(transaction) if send_customer_email

      update_node_with_tickets
      broadcast_tickets_sold
    end

    private

    def refund_order(params)
      Ticketing::OrderRefundService.new(order).execute(params)
    end

    def uncancelled_tickets
      # cannot use valid_tickets because resale tickets are invalid but still cancellable
      @uncancelled_tickets ||= scoped_tickets(:uncancelled)
    end

    def log_cancellation
      log_service(order).cancel_tickets(uncancelled_tickets, reason: @reason)
    end

    def send_email(refund_transaction)
      OrderMailer.with(order:, cancellation: @cancellation, reason: @reason.to_s, refund_transaction:)
                 .cancellation.deliver_later
    end
  end
end
