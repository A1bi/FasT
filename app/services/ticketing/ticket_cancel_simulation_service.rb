# frozen_string_literal: true

module Ticketing
  class TicketCancelSimulationService < TicketBaseService
    def cancelled_value
      @cancelled_value ||= begin
        initial_total = order.total
        cancellation = Cancellation.new

        order.tickets.each do |ticket|
          next unless ticket.in?(tickets)

          ticket.cancellation = cancellation
        end
        order.update_total

        initial_total - order.total
      end
    end

    def refund_amount
      order.balance + cancelled_value
    end

    private

    def order
      # avoid side effects of overriding in-memory order totals used in later operations
      @order ||= Order.find(super.id)
    end
  end
end
