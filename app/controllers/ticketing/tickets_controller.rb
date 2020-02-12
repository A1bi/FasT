module Ticketing
  class TicketsController < BaseController
    before_action :find_tickets_with_order
    before_action :find_event, only: %i[transfer finish_transfer]

    def cancel
      ::Ticketing::TicketCancelService.new(@tickets, params[:reason]).execute

      if retail? && params[:refund]
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
      @reservation_groups = Ticketing::ReservationGroup.all if admin?
    end

    def edit; end

    def update
      @order.edit_ticket_types(@tickets, tickets_with_type)
      @order.save

      redirect_to_order_details :edited
    end

    def init_transfer
      res = NodeApi.seating_request('setOriginalSeats', { seats: node_seats },
                                    params[:socketId])

      head res.read_body[:ok] ? :ok : :unprocessable_entity
    end

    def finish_transfer
      if (with_plan = @event.seating.plan?)
        chosen_seats = NodeApi.get_chosen_seats(params[:socketId])
      end
      date = Ticketing::EventDate.find(params[:date_id])
      updated_seats = {}

      @tickets.map! do |ticket|
        ticket.date = date
        ticket.seat = Ticketing::Seat.find(chosen_seats.shift) if with_plan

        next unless ticket.save && ticket.saved_changes?

        if with_plan
          old_date_id = ticket.attribute_before_last_save(:date_id)
          old_seat = Ticketing::Seat.find(
            ticket.attribute_before_last_save(:seat_id)
          )

          (updated_seats[ticket.date_id] || {})

          updated_seats.deep_merge!(
            old_date_id => Hash[[old_seat.node_hash(old_date_id, true)]]
          )
          updated_seats.deep_merge!(
            ticket.date.id => Hash[[ticket.seat.node_hash(ticket.date.id,
                                                          false)]]
          )
        end

        ticket
      end

      @tickets.compact!
      if @tickets.any?
        @order.log(:tickets_transferred, count: @tickets.count)
        @order.save
        NodeApi.update_seats(updated_seats) if with_plan
      end

      flash[:notice] = t('.edited', count: @tickets.count)
      head :ok
    end

    def printable
      pdf = TicketsWebPdf.new
      pdf.add_tickets(@tickets)
      send_data pdf.render, type: 'application/pdf', disposition: 'inline'
    end

    private

    def redirect_to_order_details(notice)
      redirect_to ticketing_order_path(params[:order_id]),
                  notice: t(".#{notice}", count: @tickets.count)
    end

    def find_tickets_with_order
      if action_name == 'printable'
        ticket_scope = Ticket

      else
        @order = Ticketing::Order.find(params[:order_id])
        if admin? && @order.is_a?(Ticketing::Web::Order)
          @order.admin_validations = true
        end

        ticket_scope = @order.tickets
      end

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
