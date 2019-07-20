module Ticketing
  class TicketUpdateService < TicketBaseService
    def initialize(tickets, ticket_params)
      super(tickets)
      @ticket_params = ticket_params.except(:cancelled)
    end

    def execute
      ActiveRecord::Base.transaction do
        valid_tickets.each do |ticket|
          ticket.update(@ticket_params)
        end

        valid_tickets_by_order.each do |order, tickets|
          update_order(order, tickets)
        end

        update_node
      end

      # return copy so a count wouldn't reload and thus make it empty
      valid_tickets.to_a
    end

    private

    def update_order(order, tickets)
      order.log(:enabled_resale_for_tickets, count: tickets.count) if resale?
      order.save
    end

    def update_node
      update_node_with_tickets(@tickets) if resale?
    end

    def resale?
      !@ticket_params[:resale].nil?
    end
  end
end
