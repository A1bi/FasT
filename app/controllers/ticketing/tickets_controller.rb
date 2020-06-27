# frozen_string_literal: true

module Ticketing
  class TicketsController < BaseController
    before_action :find_tickets_with_order
    before_action :find_event, only: %i[transfer finish_transfer]

    def cancel
      ::Ticketing::TicketCancelService.new(@tickets, params[:reason]).execute

      if @order.is_a?(Retail::Order) && params[:refund]
        @order.cash_refund_in_store
        @order.save
      end

      redirect_to_order_details :cancelled
    end

    def enable_resale
      ::Ticketing::TicketUpdateService.new(@tickets, resale: true).execute

      redirect_to_order_details :enabled_resale
    end

    def transfer
      return unless current_user.admin?

      @reservation_groups = Ticketing::ReservationGroup.all
    end

    def edit; end

    def update
      @order.edit_ticket_types(@tickets, tickets_with_type)
      @order.save

      redirect_to_order_details :edited
    end

    def init_transfer
      res = NodeApi.seating_request('setOriginalSeats', { seats: node_seats },
                                    params[:socket_id])

      head res.read_body[:ok] ? :ok : :unprocessable_entity
    end

    def finish_transfer
      ticket_transfer_service =
        TicketTransferService.new(@tickets,
                                  new_date_id: params[:date_id],
                                  order_id: params[:order_id],
                                  socket_id: params[:socket_id])

      return :unprocessable_entity unless ticket_transfer_service.execute

      flash[:notice] = t('.edited',
                         count: ticket_transfer_service.updates_tickets.count)
      head :ok
    end

    def printable
      pdf = TicketsWebPdf.new
      pdf.add_tickets(@tickets)
      send_data pdf.render, type: 'application/pdf', disposition: 'inline'
    end

    private

    def redirect_to_order_details(notice = nil)
      flash.notice = t(".#{notice}", count: @tickets.count) if notice
      redirect_to ticketing_order_path(params[:order_id])
    end

    def find_tickets_with_order
      if action_name == 'printable'
        ticket_scope = Ticket

      else
        @order = Ticketing::Order.find(params[:order_id])
        ticket_scope = @order.tickets
      end

      return redirect_to_order_details unless params[:ticket_ids]&.any?

      @tickets = ticket_scope.cancelled(false).where(id: params[:ticket_ids])
                             .to_a

      authorize_tickets
    end

    def authorize_tickets
      @tickets.each { |ticket| authorize ticket }
    end

    def find_event
      @event = @tickets.first.date.event
    end

    def tickets_with_type
      params[:ticketing_tickets].permit!.to_h
                                .each_with_object({}) do |(id, val), types|
        types[id.to_i] = val[:type_id].to_i
      end
    end

    def node_seats
      @tickets.each_with_object({}) do |ticket, seats|
        (seats[ticket.date.id] ||= []) << ticket.seat.id
      end
    end
  end
end
