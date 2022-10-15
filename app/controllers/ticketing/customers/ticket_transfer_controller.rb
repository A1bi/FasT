# frozen_string_literal: true

module Ticketing
  module Customers
    class TicketTransferController < BaseController
      before_action :redirect_unauthenticated

      def index
        @tickets = valid_tickets
        @dates = @event.dates.upcoming
      end

      def init
        res = NodeApi.seating_request('setOriginalSeats', { seats: node_seats }, params[:socket_id])
        head res.read_body[:ok] ? :ok : :unprocessable_entity
      end

      def finish
        ticket_transfer_service = TicketTransferService.new(valid_tickets,
                                                            new_date_id: params[:date_id],
                                                            order_id: @order.id,
                                                            socket_id: params[:socket_id],
                                                            by_customer: true,
                                                            current_user:)
        return head :unprocessable_entity unless ticket_transfer_service.execute

        OrderMailer.with(order: @order).tickets_changed.deliver_later

        flash[:notice] = t('.success')
        head :ok
      end

      private

      def node_seats
        valid_tickets.each_with_object({}) do |ticket, seats|
          (seats[ticket.date.id] ||= []) << ticket.seat.id
        end
      end
    end
  end
end
