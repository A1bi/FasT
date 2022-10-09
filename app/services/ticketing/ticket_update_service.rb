# frozen_string_literal: true

module Ticketing
  class TicketUpdateService < TicketBaseService
    def initialize(tickets, params:, current_user: nil)
      super(tickets, current_user:)
      @params = params.except(:cancelled)
    end

    def execute
      update_order_balance(:ticket_types_edited) do
        update_tickets_for_order
        order.tickets.reload
      end

      update_node_with_tickets
    end

    private

    def update_tickets_for_order
      tickets_resale = []
      tickets_updated_type = []

      valid_tickets.each do |ticket|
        next if (ticket_params = @params[ticket.id]).blank?
        next unless ticket.update(ticket_params)

        tickets_updated_type << ticket if updated_attr?(ticket, :type_id)
        tickets_resale << ticket if updated_attr?(ticket, :resale)
      end

      log_service(order).update_ticket_types(tickets_updated_type)
      log_service(order).enable_resale_for_tickets(tickets_resale)
    end

    def updated_attr?(ticket, attr)
      ticket.saved_change_to_attribute?(attr)
    end
  end
end
