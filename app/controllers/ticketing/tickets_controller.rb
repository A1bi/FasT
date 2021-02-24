# frozen_string_literal: true

module Ticketing
  class TicketsController < BaseController
    before_action :find_tickets_with_order
    before_action :find_event, only: %i[transfer finish_transfer]

    def cancel
      cancel_tickets
      refund_in_retail_store

      redirect_to_order_details :cancelled
    end

    def transfer
      return unless current_user.admin?

      @reservation_groups = Ticketing::ReservationGroup.all
    end

    def edit; end

    def update
      update_tickets(ticket_params)
      redirect_to_order_details :updated
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
                                  socket_id: params[:socket_id],
                                  current_user: current_user)

      return :unprocessable_entity unless ticket_transfer_service.execute

      flash[:notice] = t('.edited',
                         count: ticket_transfer_service.updated_tickets.count)
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

      @tickets = ticket_scope.valid.where(id: params[:ticket_ids]).to_a

      authorize_tickets
    end

    def authorize_tickets
      @tickets.each { |ticket| authorize ticket }
    end

    def find_event
      @event = @tickets.first.date.event
    end

    def ticket_params
      params[:ticketing_tickets].permit!.to_h
                                .each_with_object({}) do |(id, val), params|
        ticket = params[id.to_i] = val.slice(:resale)
        ticket[:type_id] = val[:type_id].to_i if val.key?(:type_id)
      end
    end

    def cancel_tickets
      TicketCancelService.new(@tickets, reason: params[:reason],
                                        current_user: current_user).execute
    end

    def refund_in_retail_store
      return unless params[:refund]

      OrderPaymentService.new(@order, current_user: current_user)
                         .refund_in_retail_store
    end

    def update_tickets(params)
      TicketUpdateService.new(@tickets, params: params,
                                        current_user: current_user).execute
    end

    def node_seats
      @tickets.each_with_object({}) do |ticket, seats|
        (seats[ticket.date.id] ||= []) << ticket.seat.id
      end
    end
  end
end
