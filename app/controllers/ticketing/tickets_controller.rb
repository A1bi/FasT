module Ticketing
  class TicketsController < BaseController
    before_filter :find_tickets_with_order, except: [:printable, :mark]
    before_filter :find_tickets, only: [:printable, :mark]
    ignore_restrictions
    before_filter :restrict_access, except: [:printable, :mark]
    
    def cancel
      @order.cancel_tickets(@tickets, params[:reason])
      if retail? && params[:refund]
        @order.refund
      end
      @order.save

      NodeApi.update_seats_from_tickets(@tickets)

      redirect_to_order_details :cancelled
    end
    
    def transfer
    end
    
    def init_transfer
      seats = {}
      @tickets.each do |ticket|
        (seats[ticket.date.id] ||= []) << ticket.seat.id
      end
      res = NodeApi.seating_request("setOriginalSeats", { seats: seats }, params[:seatingId])
      render json: { ok: res[:ok] }
    end
    
    def mark
      @tickets.each do |ticket|
        ticket.paid = true if params[:paid]
        ticket.picked_up = true if params[:picked_up]
        ticket.save
      end
      render json: { ok: true }
    end
    
    def finish_transfer
      ok = true
      seating = NodeApi.seating_request("getChosenSeats", { clientId: params[:seatingId] }).body
      chosen_seats = seating[:seats]
      if seating[:ok] && @tickets.count == chosen_seats.count
        date = Ticketing::EventDate.find(params[:date_id])
        updated_seats = {}
        
        @tickets.reject! do |ticket|
          ticket.date == date && chosen_seats.delete(ticket.seat.id.to_s).present?
        end
        
        @tickets.each do |ticket|
          seat = Ticketing::Seat.find(chosen_seats.shift)          
          tmp = { ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id, true)]] }
          tmp.deep_merge!({ date.id => Hash[[seat.node_hash(date.id, false)]] })
          ticket.seat = seat
          ticket.date = date
          updated_seats.deep_merge!(tmp) if ticket.save
        end
        
        NodeApi.update_seats(updated_seats)
        @order.updated_tickets(@tickets)
        @order.log(:tickets_transferred, { count: @tickets.count })
        flash[:notice] = t("ticketing.tickets.transferred", count: @tickets.count)
      else
        ok = false
      end
      render json: { ok: ok }
    end
    
    def printable
      pdf = TicketsPDF.new(true)
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
      find_tickets
      @tickets.select do |ticket|
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