# frozen_string_literal: true

module Ticketing
  class TicketCancelSimulationService < TicketBaseService
    def refund_amount
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
end
