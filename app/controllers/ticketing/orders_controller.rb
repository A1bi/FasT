# frozen_string_literal: true

module Ticketing
  class OrdersController < BaseController
    before_action :prepare_new, only: %i[new new_privileged]
    before_action :set_event_info, only: %i[new new_privileged]
    before_action :find_order, only: %i[show edit update mark_as_paid
                                        send_pay_reminder resend_confirmation
                                        resend_items approve create_billing
                                        seats]
    before_action :find_coupon, only: %i[add_coupon remove_coupon]
    before_action :prepare_billing_actions, only: %i[show create_billing]

    def new
      @type = :web
      @max_tickets = 25

      return if current_user&.admin?

      if !@event.sale_started?
        alert = t('.not_yet_available', event: @event.name, start:
                  l(@event.sale_start, format: :long))
      elsif @event.sale_ended?
        alert = t('.sale_ended', event: @event.name)
      elsif @event.sale_disabled?
        alert = @event.sale_disabled_message
      end

      redirect_to root_path, alert: alert if alert
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

    def add_coupon
      authorize Order

      if !@coupon
        error = 'invalid'
      elsif @coupon.expired?
        error = 'expired'
      else
        coupon = {
          id: @coupon.id,
          free_tickets: @coupon.free_tickets,
          seats: update_exclusive_seats(:add, @coupon.reservation_groups)
        }
      end

      render json: { coupon: coupon, error: error },
             status: error ? :unprocessable_entity : :ok
    end

    def remove_coupon
      authorize Order

      update_exclusive_seats(:remove, @coupon.reservation_groups) if @coupon

      head :ok
    end

    def enable_reservation_groups
      authorize Order

      groups = []
      (params[:groups] ||= []).each do |group_id|
        groups << Ticketing::ReservationGroup.find(group_id)
      end
      update_exclusive_seats(:set, groups)

      render json: { seats: true }
    end

    def index
      authorize Ticketing::Order

      @orders = {}

      if params[:q].present?
        found_orders, ticket = search_orders
        return if redirect_order_number_match(found_orders, ticket)

        @orders[:search] = found_orders

      else
        if current_user.admin?
          @orders[:web] = Ticketing::Web::Order.unanonymized
          @orders[:retail] = Ticketing::Retail::Order.all
        else
          @orders[:retail] = order_scope.includes(:store)
        end
        @orders.each_value { |orders| orders.limit!(20) }
      end

      @orders.each_value do |orders|
        orders
          .includes!(:tickets)
          .order!(created_at: :desc)
      end
    end

    def show
      authorize @order

      @show_check_ins = current_user.admin? && @order.tickets.any? do |t|
        t.check_ins.any? || t.date.date.past?
      end

      @billing_actions.map! do |transaction|
        [t("ticketing.orders.balancing.#{transaction}"), transaction]
      end
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
        redirect_to_order_details :updated
      else
        render :edit
      end
    end

    def mark_as_paid
      order_payment_service.mark_as_paid
      redirect_to_order_details :marked_as_paid
    end

    def approve
      authorize BankCharge

      @order.approve
      @order.save
      redirect_to_order_details :approved
    end

    def send_pay_reminder
      order_payment_service.send_reminder
      redirect_to_order_details :sent_pay_reminder
    end

    def resend_confirmation
      send_order_email(:confirmation, :resent_confirmation)
      redirect_to_order_details :resent_confirmation
    end

    def resend_items
      send_order_email(:resend_items, :resent_items)
      redirect_to_order_details :resent_items
    end

    def create_billing
      type = params[:note].to_sym

      if type.in? %i[cash_refund_in_store transfer_refund]
        authorize @order, "#{type}?"
        @order.send(params[:note])

      elsif type == :correction
        authorize @order, :correct_balance?
        amount = params[:amount].gsub(',', '.').to_f
        @order.correct_balance(amount) if amount.nonzero?
      end

      @order.save

      redirect_to_order_details :created_billing
    end

    def seats
      authorize @order

      render_cached_json([:ticketing, :orders, :show, @order,
                          @order.date.tickets]) do
        seats = {}
        [[:chosen, @order], [:taken, @order.date]].each do |type|
          seats[type.first] = type.last.tickets
                                  .where(invalidated: false).map do |t|
            t.seat&.id
          end.compact
        end
        seats
      end
    end

    private

    def new_admin
      @type = :admin
      @max_tickets = 50
      @reservation_groups = Ticketing::ReservationGroup.all

      render :new_admin
    end

    def new_retail
      @type = :retail
      @max_tickets = 35

      if !current_user.store.sale_enabled
        return redirect_to ticketing_orders_path,
                           alert: t('.sale_disabled_for_store')
      elsif @event.covid19?
        return redirect_to ticketing_orders_path,
                           alert: t('.sale_web_only_covid19')
      end

      render :new_retail
    end

    def set_event_info
      if params[:event_slug].blank?
        @events = Event.with_future_dates
        if action_name == 'new' && !current_user&.admin?
          @events = @events.select(&:on_sale?)
        end
        return redirect_to event_slug: @events.first.slug if @events.count == 1

        return render 'new_choose_event'
      end

      @event = Ticketing::Event.find_by!(slug: params[:event_slug])
      @dates = @event.dates.upcoming
      @ticket_types = @event.ticket_types.except_box_office
                            .ordered_by_availability_and_price
    end

    def search_orders
      Ticketing::OrderSearchService.new(
        params[:q],
        scope: order_scope
      ).execute
    end

    def redirect_order_number_match(orders, ticket)
      return false unless orders.count == 1

      prms = { id: orders.first }
      if ticket.present?
        prms[:ticket] = ticket.order_index
        prms[:anchor] = :tickets
      end

      redirect_to ticketing_order_path(prms)
    end

    def update_exclusive_seats(action, groups)
      return false if params[:socket_id].blank?

      seats = {}
      groups.each do |reservation_group|
        reservation_group.reservations.each do |reservation|
          next if reservation.date.blank? || reservation.seat.blank?

          (seats[reservation.date.id] ||= []) << reservation.seat.id
        end
      end
      NodeApi.seating_request("#{action}ExclusiveSeats",
                              { seats: seats }, params[:socket_id])
      seats.any?
    end

    def redirect_to_order_details(notice = nil)
      flash[:notice] = t(notice, scope: %i[ticketing orders]) if notice
      redirect_to ticketing_order_path(@order)
    end

    def find_order
      @order = order_scope.find(params[:id])
    end

    def find_coupon
      @coupon = Ticketing::Coupon.where(code: params[:code]).first
    end

    def prepare_new
      @order = authorize order_scope.new
    end

    def prepare_billing_actions
      @billing_actions = []
      if @order.billing_account.balance.positive?
        @billing_actions << :transfer_refund if current_user.admin?
        if @order.is_a? Ticketing::Retail::Order
          @billing_actions << :cash_refund_in_store
        end
      end
      @billing_actions << :correction if current_user.admin?
    end

    def send_order_email(mailer_action, log_action)
      return unless @order.is_a? Ticketing::Web::Order

      Ticketing::OrderMailer.with(order: authorize(@order))
                            .public_send(mailer_action).deliver_later
      @order.log(log_action).save
    end

    def order_scope
      policy_scope(Order)
    end

    def order_payment_service
      Ticketing::OrderPaymentService.new(authorize(@order))
    end

    def update_order_params
      params.require(:ticketing_order)
            .permit(:gender, :first_name, :last_name, :affiliation, :email,
                    :phone, :plz, :pay_method)
    end
  end
end
