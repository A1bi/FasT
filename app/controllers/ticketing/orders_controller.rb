# frozen_string_literal: true

module Ticketing
  class OrdersController < BaseController
    SEARCH_QUERY_MIN_LENGTH = 3

    before_action :prepare_new, only: %i[new new_privileged]
    before_action :set_event_info, only: %i[new new_privileged]
    before_action :find_order, only: %i[show edit update mark_as_paid send_pay_reminder
                                        resend_confirmation resend_items seats]
    before_action :prepare_billing_actions, only: %i[show]

    def index
      authorize Ticketing::Order

      if search_query.present?
        found_orders, ticket = search_orders
        return if redirect_order_number_match(found_orders, ticket)

        @orders = found_orders

      else
        @orders = order_scope.unanonymized.limit(20).order(created_at: :desc)
      end

      @orders.includes!(:tickets)
    end

    def new_privileged
      if current_user.admin?
        new_admin
      else
        new_retail
      end
    end

    def new_coupons
      authorize Order
    end

    def enable_reservation_groups
      authorize Order

      event = Event.find(params[:event_id])
      reservations = Reservation.where(group_id: params[:group_ids], date: event.dates)
      seats = reservations.each_with_object({}) do |reservation, s|
        (s[reservation.date_id] ||= []) << reservation.seat_id
      end

      NodeApi.seating_request('setExclusiveSeats', { seats: }, params[:socket_id])

      render json: { seats: true }
    end

    def show
      authorize @order

      @show_check_ins = current_user.admin? && @order.tickets.any? do |t|
        t.check_ins.any? || t.date.past?
      end
    end

    def new
      @type = :web
      @max_tickets = 25

      return if current_user&.admin?

      if !@event.sale_started?
        alert = t('.not_yet_available', event: @event.name, start: l(@event.sale_start, format: :long))
      elsif @event.sale_ended?
        alert = t('.sale_ended', event: @event.name)
      elsif @event.sale_disabled?
        alert = @event.sale_disabled_message
      end

      redirect_to root_path, alert: alert if alert
    end

    def edit
      authorize @order

      @pay_methods = Web::Order.pay_methods.keys
      @pay_methods.reject! do |method|
        method == 'charge' && !@order.charge_payment?
      end
      @pay_methods.map! do |method|
        [t(method, scope: %i[ticketing orders pay_methods]), method]
      end
    end

    def update
      if authorize(@order).update(update_order_params)
        log_service.update
        redirect_to_order_details :updated
      else
        render :edit
      end
    end

    def mark_as_paid
      authorize @order
      order_payment_service.mark_as_paid
      redirect_to_order_details :marked_as_paid
    end

    def send_pay_reminder
      authorize @order
      order_payment_service.send_reminder
      redirect_to_order_details :sent_pay_reminder
    end

    def resend_confirmation
      order_mailer.confirmation.deliver_later
      log_service.resend_confirmation
      redirect_to_order_details :resent_confirmation
    end

    def resend_items
      order_mailer.resend_items.deliver_later
      log_service.resend_items
      redirect_to_order_details :resent_items
    end

    def seats
      authorize @order

      render_cached_json([:ticketing, :orders, :show, @order, @order.date.tickets]) do
        [[:chosen, @order], [:taken, @order.date]]
          .each_with_object({}) do |type, seats|
          seats[type.first] = type.last.tickets.where(invalidated: false)
                                  .filter_map { |t| t.seat&.id }
        end
      end
    end

    private

    def new_admin
      @type = :admin
      @max_tickets = 50
      @reservation_groups = Ticketing::ReservationGroup.all
      if params[:template_order_id].present?
        @template_order = Ticketing::Order.find(params[:template_order_id])
        @preselected_date = @template_order.date
      end

      render :new_admin
    end

    def new_retail
      @type = :retail
      @max_tickets = 35

      unless current_user.store.sale_enabled
        return redirect_to ticketing_orders_path, alert: t('.sale_disabled_for_store')
      end

      render :new_retail
    end

    def set_event_info
      if params[:event_slug].blank?
        @events = Event.with_future_dates.ordered_by_dates
        @events = @events.on_sale if action_name == 'new' && !current_user&.admin?
        return redirect_to event_slug: @events.first.slug if @events.one?

        return render 'new_choose_event'
      end

      @event = Ticketing::Event.find_by!(slug: params[:event_slug])
      @dates = @event.dates.upcoming
      @preselected_date = @event.dates.find(params[:date_id]) if params[:date_id].present?
      @ticket_types = @event.ticket_types.except_box_office.ordered_by_availability_and_price
    end

    def search_query
      params[:q] if params[:q].present? && params[:q].length >= SEARCH_QUERY_MIN_LENGTH
    end

    def search_orders
      Ticketing::OrderSearchService.new(search_query, scope: order_scope).execute
    end

    def redirect_order_number_match(orders, ticket)
      return false unless orders.one?

      prms = { id: orders.first }
      if ticket.present?
        prms[:ticket] = ticket.order_index
        prms[:anchor] = :tickets
      end

      redirect_to ticketing_order_path(prms)
    end

    def redirect_to_order_details(notice = nil)
      flash[:notice] = t(notice, scope: %i[ticketing orders]) if notice
      redirect_to ticketing_order_path(@order)
    end

    def find_order
      @order = order_scope.find(params[:id])
    end

    def prepare_new
      @order = authorize order_scope.new
    end

    def prepare_billing_actions
      @billing_actions = []
      if @order.billing_account.balance.positive?
        if current_user.admin?
          @billing_actions << :refund_to_most_recent_bank_account if @order.bank_transactions.any?
          @billing_actions << :refund_to_new_bank_account
        end
        @billing_actions << :cash_refund_in_store if @order.is_a? Ticketing::Retail::Order
      end
      @billing_actions << :correction if current_user.admin?
    end

    def order_scope
      policy_scope(Order)
    end

    def order_payment_service
      OrderPaymentService.new(@order, current_user:)
    end

    def order_mailer
      OrderMailer.with(order: authorize(@order))
    end

    def log_service
      @log_service ||= LogEventCreateService.new(@order, current_user:)
    end

    def update_order_params
      params.require(:ticketing_order)
            .permit(:gender, :first_name, :last_name, :affiliation, :email, :phone, :plz, :pay_method)
    end
  end
end
