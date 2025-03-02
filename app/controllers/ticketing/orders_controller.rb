# frozen_string_literal: true

module Ticketing
  class OrdersController < BaseController
    SEARCH_QUERY_MIN_LENGTH = 3

    before_action :set_event_info, only: %i[new new_privileged]
    before_action :redirect_if_unavailable, only: %i[new new_privileged]
    before_action :prepare_new, only: %i[new new_privileged]
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
    end

    def edit
      authorize @order
      return if @order.charge_payment? || @order.stripe_payment?

      @pay_methods = %i[transfer cash box_office].map { |m| [t(m, scope: 'ticketing.orders.pay_methods'), m] }
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

      types = {
        chosen: @order.tickets.valid,
        taken: @order.date.tickets.valid,
        exclusive: @order.date.reservations
      }

      seats = types.transform_values do |scope|
        scope.where.associated(:seat).pluck(:seat_id)
      end

      render json: seats
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
      @preselected_date = preselected_date

      @ticket_types = @event.ticket_types.except_box_office.ordered_by_availability_and_price
    end

    def search_query
      params[:q] if params[:q].present? && params[:q].length >= SEARCH_QUERY_MIN_LENGTH
    end

    def search_orders
      Ticketing::OrderSearchService.new(search_query, scope: order_scope).execute
    end

    def redirect_if_unavailable
      return if (alert = unavailability_alert).nil?

      redirect_to root_path, alert:
    end

    def unavailability_alert
      return t_unavailability(:sale_ended) if @event.sale_ended?
      return if current_user&.admin?

      if !@event.sale_started?
        t_unavailability(:not_yet_available, start: l(@event.sale_start, format: :long))
      elsif @event.sale_disabled?
        @event.sale_disabled_message
      elsif @event.sold_out?
        t_unavailability("sold_out_#{@event.dates.size > 1 ? 'multiple_dates' : 'single_date'}")
      end
    end

    def t_unavailability(key, placeholders = {})
      placeholders[:event] = @event.name
      t(".#{key}", **placeholders)
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
      flash.notice = t(notice, scope: %i[ticketing orders]) if notice
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
      if @order.billing_account.credit?
        if @order.stripe_payment?
          @billing_actions << :refund_via_stripe
        elsif current_user.admin?
          @billing_actions << :refund_to_most_recent_bank_account if @order.bank_transactions.any?
          @billing_actions << :refund_to_new_bank_account
        end
        @billing_actions << :cash_refund_in_store if @order.is_a? Ticketing::Retail::Order
      end
      @billing_actions << :correction if current_user.admin?
    end

    def preselected_date
      return if params[:date_id].blank?

      date = @event.dates.find(params[:date_id])
      date unless date.cancelled? || date.sold_out?
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
      params.expect(ticketing_order: %i[gender first_name last_name affiliation email phone plz pay_method])
    end
  end
end
