module Ticketing
  class OrdersController < BaseController
    before_filter :disable_slides
    before_filter :set_event_info, only: [:new, :new_retail, :new_admin]
    before_filter :find_order, only: [:show, :mark_as_paid, :send_pay_reminder, :resend_tickets, :approve, :cancel]
    before_filter :prepare_new, only: [:new, :new_admin, :new_retail]
    ignore_restrictions
    before_filter :restrict_access
  
    def new
    end
    
    def new_admin
      @reservation_groups = Ticketing::ReservationGroup.all
    end
    
    def new_retail
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
      types = []
      types << [:web, Web, []] if admin?
      types << [:retail, Retail, [[:includes, :store]]]
      types.last.last << [:where, { store: @_retail_store }] if retail?
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
    
      redirect_to_order_details
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
      redirect_to orders_path(:ticketing_order, @order)
    end
  
    def find_order
      if retail?
        orders = Ticketing::Retail::Order.where(store: @_retail_store)
      else
        orders = Ticketing::Order.all
      end
      @order = orders.find(params[:id])
    end
    
    def prepare_new
      @order = Order.new
      @type = admin? ? :admin : retail? ? :retail : :web
    end
    
    def restrict_access
      actions = [:new, :redeem_coupon]
      if (admin? && @_member.admin?) || (retail? && @_retail_store.id)
        actions.push :index, :show, :cancel
        if @_retail_store.id
          actions.push :new_retail
        end
        if @_member.admin?
          actions.push :new_admin, :enable_reservation_groups, :mark_as_paid, :approve, :send_pay_reminder, :resend_tickets
        end
      end
      if !actions.include? action_name.to_sym
        if retail?
          return redirect_to ticketing_retail_login_path, flash: { warning: t("application.login_required") }
        else
          return redirect_to root_path, alert: t("application.access_denied")
        end
      end
    end
  end
end