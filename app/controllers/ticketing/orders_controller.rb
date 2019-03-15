module Ticketing
  class OrdersController < BaseController
    ignore_restrictions
    before_action :restrict_access
    before_action :set_event_info, only: [:new, :new_retail, :new_admin]
    before_action :find_order, only: [:show, :mark_as_paid, :send_pay_reminder, :resend_tickets, :approve, :cancel, :create_billing, :seats]
    before_action :find_coupon, only: [:add_coupon, :remove_coupon]
    before_action :prepare_new, only: [:new, :new_admin, :new_retail]
    before_action :prepare_billing_actions, only: [:show, :create_billing]

    def new
      if !@_member.admin?
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
      @show_check_ins = admin? && @order.tickets.any? { |t| t.check_ins.any? || t.date.date.past? }
      @billing_actions.map! do |transaction|
        [t("ticketing.orders.balancing." + transaction.to_s), transaction]
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

    def search
      @orders = Ticketing::Order.none

      if params[:q].present?
        max_digits = Ticketing::Order::NUMBER_MAX_DIGITS
        ticket_number_regex = Regexp.new(/\A(\d{1,#{max_digits}})(-(\d+))?\z/)

        if params[:q] =~ ticket_number_regex
          order = Ticketing::Order.where(number: $1).first
          if $3.present?
            ticket_index = $3
          end
          if order
            if retail? && (!order.is_a?(Ticketing::Retail::Order) || order.store != @_retail_store)
              flash[:alert] = t("ticketing.orders.retail_access_denied")
              return redirect_to orders_path(:ticketing_orders)
            end

            prms = { id: order.id }
            prms.merge!({ ticket: ticket_index, anchor: :tickets }) if ticket_index
            return redirect_to orders_path(:ticketing_order, prms)
          end

        else
          table = Ticketing::Order.arel_table
          if admin?
            matches = nil
            (params[:q] + " " + ActiveSupport::Inflector.transliterate(params[:q])).split(" ").uniq.each do |word|
              %i[first_name last_name affiliation].each do |column|
                term = table[column].matches("%#{word}%")
                matches = matches ? matches.or(term) : term
              end
            end
            @orders = Ticketing::Order.where(matches)
          else
            @orders = Ticketing::Retail::Order.where(store: @_retail_store).none
          end
          @orders.order!(:last_name, :first_name)
        end
      end
    end

    private

    def set_event_info
      if params[:event_slug].blank?
        @events = Event.with_future_dates
        @events = @events.select(&:on_sale?) if web? && !@_member.admin?
        return redirect_to event_slug: @events.first.slug if @events.count == 1
        return render 'new_choose_event'
      end

      @event = Ticketing::Event.find_by!(slug: params[:event_slug])
      @dates = @event.dates.where("date > ?", Time.zone.now)
      @ticket_types = @event.ticket_types.order(exclusive: :desc, price: :desc)
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
        orders = Ticketing::Retail::Order.where(store: @_retail_store)
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
      if (admin? && @_member.admin?) || (retail? && @_retail_store.id)
        actions.push :index, :show, :cancel, :seats, :search, :create_billing
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
