module Ticketing
  class TicketsController < BaseController
    before_action :find_tickets_with_order, except: :printable
    before_action :find_tickets, only: :printable
    before_action :find_event, only: [:transfer, :finish_transfer]
    ignore_restrictions
    before_action :restrict_access

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

    def edit
    end

    def update
      types = {}
      params[:ticketing_tickets].each { |id, val| types[id.to_i] = val[:type_id].to_i }
      @order.edit_ticket_types(@tickets, types)
      @order.save

      redirect_to_order_details :edited
    end

    def init_transfer
      seats = {}
      @tickets.each do |ticket|
        (seats[ticket.date.id] ||= []) << ticket.seat.id
      end
      res = NodeApi.seating_request("setOriginalSeats", { seats: seats }, params[:socketId])
      render json: { ok: res[:ok] }
    end

    def finish_transfer
      if (bound_to_seats = @event.seating.bound_to_seats?)
        chosen_seats = NodeApi.get_chosen_seats(params[:socketId])
      end
      date = Ticketing::EventDate.find(params[:date_id])
      updated_seats = {}

      @tickets.map! do |ticket|
        ticket.date = date
        ticket.seat = Ticketing::Seat.find(chosen_seats.shift) if bound_to_seats

        next unless ticket.save && ticket.saved_changes?

        if bound_to_seats
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
        NodeApi.update_seats(updated_seats) if bound_to_seats
      end

      flash[:notice] = t('ticketing.tickets.edited', count: @tickets.count)
      render json: { ok: true }
    end

    def printable
      pdf = TicketsWebPdf.new
      pdf.add_tickets(@tickets)
      send_data pdf.render, type: "application/pdf", disposition: "inline"
    end

    private

    def redirect_to_order_details(notice)
      redirect_to orders_path(:ticketing_order, params[:order_id]), notice: t("ticketing.tickets.#{notice}", count: @tickets.count)
    end

    def find_tickets
      @tickets = Ticketing::Ticket.find(params[:ticket_ids])
    end

    def find_tickets_with_order
      @order = Ticketing::Order.find(params[:order_id])
      deny_access if retail? && !@order.is_a?(Ticketing::Retail::Order)
      @order.admin_validations = true if admin? && @order.is_a?(Ticketing::Web::Order)

      @tickets = @order.tickets
                       .cancelled(false).where(id: params[:ticket_ids]).to_a
    end

    def find_event
      @event = @tickets.first.date.event
    end

    def restrict_access
      if (admin? && !current_user&.admin?) ||
         (retail? && !retail_store_signed_in?)
        deny_access
      end
    end

    def deny_access
      return redirect_to root_path, alert: t("application.access_denied")
    end
  end
end
