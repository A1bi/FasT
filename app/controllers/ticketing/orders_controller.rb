module Ticketing
  class OrdersController < BaseController
    ignore_restrictions
    before_action :restrict_access
    before_action :check_retail_sale_enabled, only: :new_retail
    before_action :set_event_info, only: [:new, :new_retail, :new_admin]
    before_action :find_order, only: [:show, :edit, :update, :mark_as_paid, :send_pay_reminder, :resend_confirmation, :resend_tickets, :approve, :cancel, :create_billing, :seats]
    before_action :find_coupon, only: [:add_coupon, :remove_coupon]
    before_action :prepare_new, only: [:new, :new_admin, :new_retail]
    before_action :prepare_billing_actions, only: [:show, :create_billing]
    before_action :redirect_if_no_web_order, only: [:edit, :update]

    def new
      if !current_user&.admin?
        if !@event.sale_started?
          redirect_to root_path, alert: t("ticketing.orders.not_yet_available", event: @event.name, start: l(@event.sale_start, format: :long))
        elsif @event.sale_ended?
          redirect_to root_path, alert: t("ticketing.orders.sale_ended", event: @event.name)
        elsif @event.sale_disabled?
          redirect_to root_path, alert: @event.sale_disabled_message
        end
      end
      @max_tickets = 25
    end

    def new_admin
      @reservation_groups = Ticketing::ReservationGroup.all
      @max_tickets = 50
    end

    def new_retail
      @max_tickets = 35
    end

    def add_coupon
      response = { ok: false }

      if !@coupon
        response[:error] = "not found"
      elsif @coupon.expired?
        response[:error] = "expired"
      else
        response = {
          ok: true,
          coupon: {
            id: @coupon.id,
            free_tickets: @coupon.free_tickets,
            seats: update_exclusive_seats(:add, @coupon.reservation_groups)
          }
        }
      end

      render json: response
    end

    def remove_coupon
      response = { ok: false }

      if @coupon
        update_exclusive_seats(:remove, @coupon.reservation_groups)
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
      update_exclusive_seats(:set, groups)

      response = { ok: true, seats: true }

      render json: response
    end

    def index
      @orders = {}

      if params[:q].present?
        found_orders, ticket = search_orders
        return if redirect_order_number_match(found_orders, ticket)

        @orders[:search] = found_orders

      else
        @orders[:web] = Ticketing::Web::Order.all if admin?
        @orders[:retail] = Ticketing::Retail::Order.includes(:store)
        @orders[:retail].where!(store: current_retail_store) if retail?
        @orders.values.each do |orders|
          orders
            .where!('created_at > ?', 1.month.ago)
            .limit!(20)
        end
      end

      @orders.values.each do |orders|
        orders
          .includes!(:tickets)
          .order!(created_at: :desc)
      end
    end

    def show
      @show_check_ins = admin? && @order.tickets.any? { |t| t.check_ins.any? || t.date.date.past? }
      @billing_actions.map! do |transaction|
        [t("ticketing.orders.balancing." + transaction.to_s), transaction]
      end
    end

    def edit
      @pay_methods = Web::Order.pay_methods.keys
      @pay_methods.reject! do |method|
        method == 'charge' && !@order.charge_payment?
      end
      @pay_methods.map! do |method|
        [t(method, scope: %i[ticketing orders pay_methods]), method]
      end
    end

    def update
      if @order.update(update_order_params)
        redirect_to_order_details :updated
      else
        render :edit
      end
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

    def resend_confirmation
      if @order.is_a? Ticketing::Web::Order
        @order.send_confirmation(log: true)
        @order.save
      end
      redirect_to_order_details :resent_confirmation
    end

    def resend_tickets
      if @order.is_a? Ticketing::Web::Order
        @order.resend_tickets
        @order.save
      end
      redirect_to_order_details :resent_tickets
    end

    def create_billing
      if @billing_actions.include? params[:note].to_sym
        if [:cash_refund_in_store, :transfer_refund].include? params[:note].to_sym
          @order.send(params[:note])
        else
          amount = params[:amount].gsub(",", ".").to_f
          @order.correct_balance(amount) if amount != 0
        end
        @order.save
      end
      redirect_to_order_details :created_billing
    end

    def seats
      render_cached_json [:ticketing, :orders, :show, @order, @order.date.tickets] do
        seats = {}
        [[:chosen, @order], [:taken, @order.date]].each do |type|
          seats[type.first] = type.last.tickets.where(invalidated: false).map do |t|
            t.seat&.id
          end.compact
        end
        seats
      end
    end

    private

    def set_event_info
      if params[:event_slug].blank?
        @events = Event.with_future_dates
        @events = @events.select(&:on_sale?) if web? && !current_user&.admin?
        return redirect_to event_slug: @events.first.slug if @events.count == 1
        return render 'new_choose_event'
      end

      @event = Ticketing::Event.find_by!(slug: params[:event_slug])
      @dates = @event.dates.upcoming
      @ticket_types = @event.ticket_types.order(exclusive: :desc, price: :desc)
    end

    def search_orders
      Ticketing::OrderSearchService.new(
        params[:q],
        retail_store: retail? ? current_retail_store : nil
      ).execute
    end

    def redirect_order_number_match(orders, ticket)
      return false unless orders.count == 1

      prms = { id: orders.first }
      if ticket.present?
        prms[:ticket] = ticket.order_index
        prms[:anchor] = :tickets
      end

      redirect_to orders_path(:ticketing_order, prms)
    end

    def update_exclusive_seats(action, groups)
      return false if params[:socketId].blank?
      seats = {}
      groups.each do |reservation_group|
        reservation_group.reservations.each do |reservation|
          next if reservation.date.blank? || reservation.seat.blank?
          (seats[reservation.date.id] ||= []) << reservation.seat.id
        end
      end
      NodeApi.seating_request(action.to_s + "ExclusiveSeats", { seats: seats }, params[:socketId])
      seats.any?
    end

    def redirect_to_order_details(notice = nil)
      flash[:notice] = t(notice, scope: [:ticketing, :orders]) if notice
      redirect_to orders_path(:ticketing_order, @order)
    end

    def find_order
      if retail?
        orders = Ticketing::Retail::Order.where(store: current_retail_store)
      else
        orders = Ticketing::Order.all
      end
      @order = orders.find(params[:id])
    end

    def find_coupon
      @coupon = Ticketing::Coupon.where(code: params[:code]).first
    end

    def prepare_new
      @order = Order.new
      @type = admin? ? :admin : retail? ? :retail : :web
    end

    def prepare_billing_actions
      @billing_actions = []
      if @order.billing_account.balance > 0
        if admin?
          @billing_actions << :transfer_refund
        end
        if @order.is_a? Ticketing::Retail::Order
          @billing_actions << :cash_refund_in_store
        end
      end
      @billing_actions << :correction if admin?
    end

    def restrict_access
      actions = [:new, :add_coupon, :remove_coupon]
      if (admin? && current_user&.admin?) || (retail? && retail_store_signed_in?)
        actions.push :index, :show, :cancel, :seats, :search, :create_billing
        if retail_store_signed_in?
          actions.push :new_retail
        end
        if current_user&.admin?
          actions.push :new_admin, :edit, :update, :enable_reservation_groups, :mark_as_paid, :approve, :send_pay_reminder, :resend_confirmation, :resend_tickets
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

    def check_retail_sale_enabled
      return if current_retail_store.sale_enabled

      redirect_to ticketing_retail_orders_path,
                  alert: t('.sale_disabled_for_store')
    end

    def redirect_if_no_web_order
      redirect_to_order_details unless @order.is_a? Web::Order
    end

    def update_order_params
      params.require(:ticketing_order).permit(:gender, :first_name, :last_name, :affiliation, :email, :phone, :plz, :pay_method)
    end
  end
end
