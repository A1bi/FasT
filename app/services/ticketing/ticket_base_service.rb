# frozen_string_literal: true

module Ticketing
  class TicketBaseService
    class TicketsFromDifferentOrdersError < StandardError; end

    include NodeUpdating
    include Broadcasting

    def initialize(tickets, current_user: nil)
      raise TicketsFromDifferentOrdersError if tickets.pluck(:order_id).uniq.count > 1

      @tickets = tickets
      @current_user = current_user
    end

    private

    def tickets
      return @tickets if @tickets.is_a? ActiveRecord::Relation

      # we might get an array of records so turn it into a relation
      @tickets = ::Ticketing::Ticket.where(id: @tickets.pluck(:id))
    end

    def order
      tickets.first.order
    end

    def valid_tickets
      @valid_tickets ||= scoped_tickets(:valid)
    end

    def scoped_tickets(scope)
      tickets.public_send(scope).load
    end

    def update_order_balance(note, &)
      OrderBillingService.new(order).update_balance(note, &)
    end

    def log_service(loggable)
      LogEventCreateService.new(loggable, current_user: @current_user)
    end

    def update_node_with_tickets
      super(tickets)
    end

    def broadcast_tickets_sold(tickets: self.tickets)
      super
    end
  end
end
