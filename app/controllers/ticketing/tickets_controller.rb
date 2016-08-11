module Ticketing
  class TicketsController < BaseController
    before_action :find_tickets_with_order, except: [:printable, :mark]
    before_action :find_tickets, only: [:printable, :mark]
    before_action :find_event, only: [:transfer, :finish_transfer]
    ignore_restrictions
    before_action :restrict_access

    def cancel
      @order.cancel_tickets(@tickets, params[:reason])
      if retail? && params[:refund]
        @order.cash_refund_in_store
      end

      save_order_and_update_node_with_tickets(@order, @tickets)

      redirect_to_order_details :cancelled
    end

    def enable_resale
      @order.enable_resale_for_tickets(@tickets)

      save_order_and_update_node_with_tickets(@order, @tickets)

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
      res = NodeApi.seating_request("setOriginalSeats", { seats: seats }, params[:seatingId])
      render json: { ok: res[:ok] }
    end

    def finish_transfer
      ok = true
      bound_to_seats = @event.seating.bound_to_seats?

      if bound_to_seats
        seating = NodeApi.seating_request("getChosenSeats", { clientId: params[:seatingId] }).body
        chosen_seats = seating[:seats]
      end

      if !bound_to_seats || (seating[:ok] && @tickets.count == chosen_seats.count)
        date = Ticketing::EventDate.find(params[:date_id])

        if bound_to_seats
          updated_seats = {}

          @tickets.reject! do |ticket|
            ticket.date == date && chosen_seats.delete(ticket.seat.id.to_s).present?
          end
        end

        @tickets.each do |ticket|
          if bound_to_seats
            seat = Ticketing::Seat.find(chosen_seats.shift)
            tmp = { ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id, true)]] }
            tmp.deep_merge!({ date.id => Hash[[seat.node_hash(date.id, false)]] })
            updated_seats.deep_merge!(tmp)
            ticket.seat = seat
          end
          ticket.date = date
        end

        @order.log(:tickets_transferred, { count: @tickets.count })
        if @order.save && bound_to_seats
          NodeApi.update_seats(updated_seats)
        end

        flash[:notice] = t("ticketing.tickets.edited", count: @tickets.count)
      else
        ok = false
      end
      render json: { ok: ok }
    end

    def printable
      pdf = TicketsWebPDF.new
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

      # @tickets = @order.tickets.cancelled(false).find(params[:ticket_ids])
      # workaround: autosave is not triggered when fetching the tickets like shown above
      @tickets = @order.tickets.select do |ticket|
        params[:ticket_ids].include?(ticket.id.to_s) && !ticket.cancelled?
      end
    end

    def find_event
      @event = @tickets.first.date.event
    end

    def save_order_and_update_node_with_tickets(order, tickets)
      if order.save
        NodeApi.update_seats_from_records(tickets)
      end
    end

    def restrict_access
      if (admin? && !@_member.admin?) || (retail? && !@_retail_store.id)
        deny_access
      end
    end

    def deny_access
      return redirect_to root_path, alert: t("application.access_denied")
    end
  end
end
