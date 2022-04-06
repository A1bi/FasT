# frozen_string_literal: true

module Ticketing
  class TicketBaseService
    include NodeUpdating

    def initialize(tickets, current_user: nil)
      @tickets = tickets
      @current_user = current_user
    end

    private

    def tickets
      return @tickets if @tickets.is_a? ActiveRecord::Relation

      # we might get an array of records so turn it into a relation
      @tickets = ::Ticketing::Ticket.where(id: @tickets.pluck(:id))
    end

    def valid_tickets
      @valid_tickets ||= scoped_tickets(:valid)
    end

    def valid_tickets_by_order
      @valid_tickets_by_order ||= scoped_tickets_by_order(:valid)
    end

    def scoped_tickets_by_order(scope)
      scoped_tickets(scope).group_by(&:order)
    end

    def scoped_tickets(scope)
      # need to load and memoize because the valid tickets will be invalid after
      # the first step of cancelling them (see execute method)
      tickets.public_send(scope).includes(:order).load
    end

    def update_order_balance(order, note, &)
      OrderBillingService.new(order).update_balance(note, &)
    end

    def log_service(loggable)
      LogEventCreateService.new(loggable, current_user: @current_user)
    end
  end
end
