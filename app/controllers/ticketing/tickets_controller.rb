module Ticketing
  class TicketsController < BaseController
    before_filter :disable_slides
    before_filter :find_tickets
    ignore_restrictions
    before_filter :restrict_access
    
    def edit_multiple
      case params[:edit_action].to_sym
      when :cancel
        @order.cancel_tickets(@tickets, params[:reason])
        NodeApi.update_seats_from_tickets(@tickets)
        redirect_to_order_details :cancelled
      when :transfer
        render :transfer
      end      
    end
    
    def init_transfer
      seats = {}
      @tickets.each do |ticket|
        (seats[ticket.date.id] ||= []) << ticket.seat.id
      end
      res = NodeApi.seating_request("setOriginalSeats", { seats: seats }, params[:seatingId])
      render json: { ok: res[:ok] }
    end
    
    def transfer
      ok = true
      seating = NodeApi.seating_request("getChosenSeats", { clientId: params[:seatingId] }).body
      chosenSeats = seating[:seats]
      if seating[:ok] && @tickets.count == chosenSeats.count
        date = Ticketing::EventDate.find(params[:date_id])
        updatedSeats = {}
        @tickets.each do |ticket|
          seat = Ticketing::Seat.find(chosenSeats.shift)
          updatedSeats.deep_merge!({ ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]] })
          updatedSeats.deep_merge!({ date.id => Hash[[seat.node_hash(date.id)]] })
          ticket.seat = seat
          ticket.date = date
          ticket.save
        end
        NodeApi.update_seats(updatedSeats)
        flash[:notice] = t("ticketing.tickets.transferred", count: @tickets.count)
      else
        ok = false
      end
      render json: { ok: ok }
    end
  
    private
  
    def redirect_to_order_details(notice)
      redirect_to orders_path(:ticketing_order, params[:order_id]), notice: t("ticketing.tickets.#{notice}", count: @tickets.count)
    end
  
    def find_tickets
      @order = Ticketing::Order.find(params[:order_id])
      deny_access if retail? && !@order.is_a?(Ticketing::Retail::Order)
      @order.admin_validations = true if admin? && @order.is_a?(Ticketing::Web::Order)
      @tickets = Ticketing::Ticket.find(params[:ticket_ids]).select do |ticket|
        ticket.order == @order && !ticket.cancelled?
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