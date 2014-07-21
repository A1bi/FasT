module Ticketing
  class OrdersController < BaseController
    before_filter :set_event_info, only: [:new, :new_retail, :new_admin]
    before_filter :find_order, only: [:show, :mark_as_paid, :send_pay_reminder, :resend_tickets, :approve, :cancel, :seats]
    before_filter :prepare_new, only: [:new, :new_admin, :new_retail]
    ignore_restrictions
    before_filter :restrict_access
  
    def new
      if !@_member.admin? && @event.sale_start && @event.sale_start > Time.zone.now
        redirect_to root_path, alert: t("ticketing.orders.not_yet_available", event: @event.name, start: l(@event.sale_start, format: :long))
      end
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
      @orders = {}
      @orders[:web] = Ticketing::Web::Order.all if admin?
      @orders[:retail] = Ticketing::Retail::Order.includes(:store)
      @orders[:retail].where!(store: @_retail_store) if retail?
      
      @orders.each do |type, orders|
        table = orders.arel_table
        orders
          .includes!(:tickets)
          .where!(table[:created_at].gt(Time.now - 1.month))
          .order!(created_at: :desc)
          .limit!(20)
      end
    end
  
    def show
    end
  
    def mark_as_paid
      @order.mark_as_paid if !@order.cancelled?
      redirect_to_order_details :marked_as_paid
    end
  
    def approve
      @order.approve if !@order.cancelled?
      redirect_to_order_details :approved
    end
  
    def send_pay_reminder
      @order.send_pay_reminder if @order.is_a?(Ticketing::Web::Order) && !@order.cancelled?
      redirect_to_order_details :sent_pay_reminder
    end
  
    def resend_tickets
      @order.resend_tickets if @order.is_a? Ticketing::Web::Order
      redirect_to_order_details :resent_tickets
    end
  
    def cancel
      @order.cancel(params[:reason])
    
      NodeApi.update_seats_from_tickets(@order.tickets)
    
      redirect_to_order_details :cancelled
    end
    
    def seats
      render_cached_json [:ticketing, :orders, :show, @order, @order.tickets] do
        {
          seats: @order.tickets.map { |t| t.seat.id if !t.cancelled? }.compact
        }
      end
    end
    
    def search
      if params[:q].present?
        if params[:q] =~ /\A(1|7)(\d{6})\z/
          if $1 == "1"
            order = Ticketing::Order.where(number: $2).first
          else
            ticket = Ticketing::Ticket.where(number: $2).first
            order = ticket.order if ticket
          end
          if order
            if retail? && (!order.is_a?(Ticketing::Retail::Order) || order.store != @_retail_store)
              flash[:alert] = t("ticketing.orders.retail_access_denied")
              return redirect_to orders_path(:ticketing_orders)
            end
            return respond_to do |format|
              format.html do
                prms = { id: order.id }
                prms.merge!({ ticket: ticket.id, anchor: :tickets }) if ticket
                redirect_to orders_path(:ticketing_order, prms)
              end
              format.json do
                render json: {
                  order: order_search_hash(order),
                  ticket: (ticket) ? ticket.id.to_s : nil 
                }
              end
            end
          end
      
        else
          table = Ticketing::Order.arel_table
          if admin?
            @orders = Ticketing::Order
              .where(table[:first_name].matches("%#{params[:q]}%")
              .or(table[:last_name].matches("%#{params[:q]}%")))
          else
            @orders = Ticketing::Retail::Order.where(store: @_retail_store).none
          end
          @orders.order!(:last_name, :first_name)
        end
      else
        @orders = Ticketing::Order.none
      end
      
      respond_to do |format|
        format.html
        format.json do
          render json: {
            orders: @orders.map { |o| order_search_hash(o) }
          }
        end
      end
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
      NodeApi.seating_request("setExclusiveSeats", { seats: seats }, params[:seatingId]) if seats.any? || even_if_empty
      seats
    end
  
    def redirect_to_order_details(notice = nil)
      flash[:notice] = t(notice, scope: [:ticketing, :orders]) if notice
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
      actions = [:new, :redeem_coupon, :search]
      if (admin? && @_member.admin?) || (retail? && @_retail_store.id)
        actions.push :index, :show, :cancel, :seats, :search
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
    
    def order_search_hash(order)
      order.api_hash([:personal, :log_events, :tickets, :status], [:status])
    end
  end
end