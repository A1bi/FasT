module Ticketing
  class OrdersController < BaseController
    before_filter :set_event_info, only: [:new, :new_retail, :new_admin]
    before_filter :find_order, only: [:show, :mark_as_paid, :send_pay_reminder, :resend_tickets, :approve, :cancel, :seats]
    before_filter :prepare_new, only: [:new, :new_admin, :new_retail]
    ignore_restrictions
    before_filter :restrict_access

    def new
      if !@_member.admin? && !@event.sale_started?
        redirect_to root_path, alert: t("ticketing.orders.not_yet_available", event: @event.name, start: l(@event.sale_start, format: :long))
      end
    end

    def new_admin
      @reservation_groups = Ticketing::ReservationGroup.all
    end

    def new_retail
    end

    def add_coupon
      response = { ok: false }
      
      coupon = Ticketing::Coupon.where(code: params[:code]).first
      if !coupon
        response[:error] = "not found"
      elsif coupon.expired?
        response[:error] = "expired"
      else
        response = {
          ok: true,
          coupon: {
            id: coupon.id,
            seats: update_exclusive_seats(:add, coupon.reservation_groups),
            ticket_types: coupon.ticket_type_assignments.map do |assignment|
              { id: assignment.ticket_type.id, number: assignment.number }
            end
          }
        }
      end

      render json: response
    end
    
    def remove_coupon
      response = { ok: false }
      
      coupon = Ticketing::Coupon.where(code: params[:code]).first
      if coupon
        update_exclusive_seats(:remove, coupon.reservation_groups)
        response = {
          ok: true
        }
      end

      render json: response
    end

    def enable_reservation_groups
      groups = []
      (params[:groups] ||= []).each do |group_id|
        groups << Ticketing::ReservationGroup.find(group_id)
      end
      update_exclusive_seats(:add, groups)

      response = { ok: true, seats: true }

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
      if !@order.cancelled? && @order.billing_account.outstanding?
        @order.mark_as_paid
        @order.save
      end
      redirect_to_order_details :marked_as_paid
    end

    def approve
      @order.approve
      @order.save
      redirect_to_order_details :approved
    end

    def send_pay_reminder
      if @order.is_a?(Ticketing::Web::Order) && @order.billing_account.outstanding?
        @order.send_pay_reminder
        @order.save
      end
      redirect_to_order_details :sent_pay_reminder
    end

    def resend_tickets
      if @order.is_a? Ticketing::Web::Order
        @order.resend_tickets
        @order.save
      end
      redirect_to_order_details :resent_tickets
    end

    def cancel
      @order.cancel_tickets(@order.tickets, params[:reason])
      @order.save

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
            matches = nil
            (params[:q] + " " + ActiveSupport::Inflector.transliterate(params[:q])).split(" ").uniq.each do |term|
              match = table[:first_name].matches("%#{term}%").or(table[:last_name].matches("%#{term}%"))
              matches = matches ? matches.or(match) : match
            end
            @orders = Ticketing::Order.where(matches)
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
  		@ticket_types = Ticketing::TicketType.order(price: :desc)
    end
    
    def update_exclusive_seats(action, groups)
      seats = {}
      (groups).each do |reservation_group|
        reservation_group.reservations.each do |reservation|
          (seats[reservation.date.id] ||= []) << reservation.seat.id
        end
      end
      if seats.any?
        NodeApi.seating_request(action.to_s + "ExclusiveSeats", { seats: seats }, params[:seatingId])
        true
      end
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
      actions = [:new, :add_coupon, :remove_coupon, :search]
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
