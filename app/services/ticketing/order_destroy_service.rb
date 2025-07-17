# frozen_string_literal: true

module Ticketing
  class OrderDestroyService
    include NodeUpdating
    include Broadcasting

    def initialize(order)
      @order = order
    end

    def execute
      tickets = @order.tickets.records
      @order.destroy
      update_node_with_tickets(tickets)
      broadcast_tickets_sold
    end
  end
end
