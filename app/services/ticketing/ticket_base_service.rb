module Ticketing
  class TicketBaseService
    include NodeUpdating

    def initialize(tickets)
      @tickets = tickets
    end

    private

    def tickets
      return @tickets if @tickets.is_a? ActiveRecord::Relation

      # we might get an array of records so turn it into a relation
      @tickets = ::Ticketing::Ticket.where(id: @tickets.pluck(:id))
    end

    def valid_tickets
      # need to load and memoize because the valid tickets will be invalid after
      # the first step of cancelling them (see execute method)
      @valid_tickets ||= tickets.cancelled(false).includes(:order).load
    end

    def valid_tickets_by_order
      valid_tickets.group_by(&:order)
    end
  end
end
