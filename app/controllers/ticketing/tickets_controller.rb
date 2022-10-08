# frozen_string_literal: true

module Ticketing
  class TicketsController < BaseController
    before_action :find_order
    before_action :find_tickets, except: %i[cancel printable]
    before_action :find_event, only: %i[transfer finish_transfer]

    def cancel
      find_tickets(ticket_scope: @order.tickets.uncancelled)
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
                                  current_user:)

      return head :unprocessable_entity unless ticket_transfer_service.execute

      flash[:notice] = t('.updated')
      head :ok
    end

    def printable
      find_tickets(ticket_scope: Ticket.valid)
      pdf = TicketsWebPdf.new
      pdf.add_tickets(@tickets)
      send_data pdf.render, type: 'application/pdf', disposition: 'inline'
    end

    private

    def redirect_to_order_details(notice = nil)
      flash.notice = t(".#{notice}", count: @tickets.size) if notice
      redirect_to ticketing_order_path(params[:order_id])
    end

    def find_order
      @order = Ticketing::Order.find(params[:order_id])
    end

    def find_tickets(ticket_scope: @order.tickets.valid)
      @tickets = ticket_scope.where(id: params[:ticket_ids])
      raise ActiveRecord::RecordNotFound if @tickets.none?

      @tickets.each { |ticket| authorize(ticket) }
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
      refund = params.permit(:use_most_recent, :iban, :name) if params[:transfer_refund]
      TicketCancelService.new(@tickets, reason: params[:reason], current_user:).execute(refund:)
    end

    def refund_in_retail_store
      return unless params[:retail_refund] && current_user.retail?

      OrderBillingService.new(@order).refund_in_retail_store
    end

    def update_tickets(params)
      TicketUpdateService.new(@tickets, params:, current_user:).execute
    end

    def node_seats
      @tickets.each_with_object({}) do |ticket, seats|
        (seats[ticket.date.id] ||= []) << ticket.seat.id
      end
    end
  end
end
