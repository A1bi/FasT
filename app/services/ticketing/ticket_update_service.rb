# frozen_string_literal: true

module Ticketing
  class TicketUpdateService < TicketBaseService
    def initialize(tickets, params:, current_user: nil)
      super(tickets, current_user: current_user)
      @params = params.except(:cancelled)
    end

    def execute
      ActiveRecord::Base.transaction do
        valid_tickets.each do |ticket|
          ticket.update(@params)
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
      return unless order.save

      log_service(order).enable_resale_for_tickets(tickets) if resale?
    end

    def update_node
      update_node_with_tickets(@tickets) if resale?
    end

    def resale?
      !@params[:resale].nil?
    end
  end
end
