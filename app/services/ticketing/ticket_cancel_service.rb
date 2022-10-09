# frozen_string_literal: true

module Ticketing
  class TicketCancelService < TicketBaseService
    class TicketsFromDifferentOrdersError < StandardError; end

    def initialize(tickets, reason:, current_user: nil)
      raise TicketsFromDifferentOrdersError if tickets.pluck(:order_id).uniq.count > 1

      super(tickets, current_user:)
      @reason = reason
    end

    def execute(refund: nil, send_customer_email: true)
      return if uncancelled_tickets.none?

      update_order_balance(order, :cancellation) do
        Cancellation.create(
          reason: @reason,
          tickets: uncancelled_tickets
        )
        order.tickets.reload
      end

      log_cancellation
      transaction = refund_order(refund) if refund.present?
      send_email(transaction) if send_customer_email

      update_node_with_tickets(@tickets)
    end

    private

    def refund_order(params)
      Ticketing::OrderRefundService.new(order).execute(params)
    end

    def uncancelled_tickets
      # cannot use valid_tickets because resale tickets are invalid but still cancellable
      @uncancelled_tickets ||= scoped_tickets(:uncancelled)
    end

    def order
      tickets.first.order
    end

    def log_cancellation
      log_service(order).cancel_tickets(uncancelled_tickets, reason: @reason)
    end

    def send_email(bank_transaction)
      OrderMailer.with(order:, reason: @reason.to_s, bank_transaction:).cancellation.deliver_later
    end
  end
end
