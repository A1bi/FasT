module Ticketing
  class OrdersController < BaseController
    before_filter :disable_slides
    before_filter :set_event_info, only: [:new, :new_retail, :new_service]
    before_filter :find_order, only: [:show, :mark_as_paid, :send_pay_reminder, :resend_tickets, :approve, :cancel]
    restrict_access_to_group :admin, only: [:new_service, :enable_reservation_groups]
    ignore_restrictions
  
    def new
      @type = :web
    end
  
    def new_retail
      @type = :retail
      @store = @_retail_store
    end
  
    def new_service
      @type = :service
      @reservation_groups = Ticketing::ReservationGroup.scoped
    end
  
    def redeem_coupon
      response = { ok: false }
      coupon = Ticketing::Coupon.where(code: params[:code]).first
      if !coupon
        response[:error] = "not found"
      elsif coupon.expired?
        response[:error] = "expired"
      else
        response[:ok] = true
      
        response[:seats] = set_exclusive_seats(coupon.reservation_groups).any?
      
        response[:ticket_types] = coupon.ticket_type_assignments.map do |assignment|
          { id: assignment.ticket_type.id, number: assignment.number }
        end
      end
    
      render json: response
    end
  
    def enable_reservation_groups
      groups = []
      (params[:groups] ||= []).each do |group_id|
        groups << Ticketing::ReservationGroup.find(group_id)
      end
    
      response = { ok: true, seats: set_exclusive_seats(groups, true).any? }
    
      render json: response
    end
  
    def index
      types = [
        [:web, Web, []],
        [:retail, Retail, [
          [:includes, :store]
        ]]
      ]
      @orders = {}
      types.each do |type|
        @orders[type[0]] = type[1]::Order
          .includes(:tickets)
          .order(created_at: :desc)
          .limit(20)
        type[2].each do |additional|
          @orders[type[0]] = @orders[type[0]].send(additional[0], additional[1])
        end
      end
    end
  
    def show
    end
  
    def mark_as_paid
      @order.mark_as_paid if !@order.cancelled?
      redirect_to_order_details
    end
  
    def approve
      @order.approve if !@order.cancelled?
      redirect_to_order_details
    end
  
    def send_pay_reminder
      @order.send_pay_reminder if @order.is_a?(Ticketing::Web::Order) && !@order.cancelled?
      redirect_to_order_details
    end
  
    def resend_tickets
      @order.resend_tickets if @order.is_a? Ticketing::Web::Order
      redirect_to_order_details
    end
  
    def cancel
      @order.cancel(params[:reason])
      @order.log(:cancelled)
    
      seats = {}
      @order.tickets.each do |ticket|
        ticket.cancellation = @order.cancellation
        ticket.save
        seats.deep_merge! ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]]
      end
      NodeApi.update_seats(seats)
    
      OrderMailer.cancellation(@order).deliver
    
      redirect_to ticketing_order_path(@order)
    end
  
    private
  
  	def set_event_info
  		@event = Ticketing::Event.current
      @dates = @event.dates.where("date > ?", Time.zone.now)
  		@seats = Ticketing::Seat.all
  		@ticket_types = Ticketing::TicketType.order(:price)
    end
  
    def set_exclusive_seats(groups, even_if_empty = false)
      seats = {}
      (groups).each do |reservation_group|
        reservation_group.reservations.each do |reservation|
          (seats[reservation.date.id] ||= []) << reservation.seat.id
        end
      end
      NodeApi.seating_request("setExclusiveSeats", { clientId: params[:seatingId], seats: seats }) if seats.any? || even_if_empty
      seats
    end
  
    def redirect_to_order_details
      redirect_to ticketing_order_path(@order)
    end
  
    def find_order
      @order = Ticketing::Order.find(params[:id])
    end
  end
end