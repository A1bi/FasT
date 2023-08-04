# frozen_string_literal: true

module Ticketing
  class OrderCreateService < BaseService
    include OrderingType

    attr_accessor :current_box_office

    def initialize(params, current_user: nil, current_box_office: nil)
      super(current_user, params)
      @current_box_office = current_box_office
    end

    def execute
      @order = order_class.new

      if retail?
        @order.store = current_user&.store

      elsif box_office?
        @order.box_office = current_box_office

      else
        @order.attributes = order_params[:address]
        create_payment
      end

      validate_event

      update_balance do
        create_items
        redeem_coupons(credit: false)
      end
      redeem_coupons(free_tickets: false)
      settle_balance

      finalize_order

      @order
    end

    private

    def validate_event
      @order.errors.add(:event, 'Ticket sale currently disabled') if sale_disabled?
      @order.errors.add(:event, 'Sold out') if sold_out?
    end

    def create_payment
      @order.pay_method = order_params[:payment][:method]
      return unless @order.charge_payment?

      charge_params = order_params[:payment].slice(:name, :iban)
      @order.bank_transactions.new(charge_params)
    end

    def create_items
      TicketCreateService.new(@order, date, current_user, params).execute
      CouponCreateService.new(@order, current_user, order_params).execute
    end

    def redeem_coupons(options)
      coupon_redeem_service.execute(**options)
    end

    def coupon_redeem_service
      @coupon_redeem_service ||= CouponRedeemService.new(@order, date, current_user, order_params)
    end

    def update_balance(&)
      billing_service.update_balance(:order_created, &)
    end

    def settle_balance
      billing_service.settle_balance_with_bank_transaction
      billing_service.settle_balance_with_retail_account
    end

    def finalize_order
      ActiveRecord::Base.transaction do
        contexts = [:create, (:unprivileged_order unless admin?)]
        next unless @order.save(context: contexts)

        log_order_creation

        update_node_seats

        send_confirmation

        suppress_in_production(StandardError) do
          send_push_notifications
        end
      end
    end

    def log_order_creation
      LogEventCreateService.new(@order, current_user:).create
    end

    def send_confirmation
      OrderMailer.with(order: @order).confirmation.deliver_later
    end

    def send_push_notifications
      OrderPushNotificationsJob.perform_later(@order, admin: admin?)
    end

    def update_node_seats
      return unless date&.event&.seating&.plan?

      NodeApi.update_seats_from_records(@order.tickets)
    end

    def billing_service
      @billing_service ||= OrderBillingService.new(@order)
    end

    def order_class
      if retail?
        Retail::Order
      elsif box_office?
        BoxOffice::Order
      else
        Web::Order
      end
    end

    def order_params
      params[:order]
    end

    def date
      return if order_params[:date].blank?

      @date ||= EventDate.find(order_params[:date])
    end

    def sale_disabled?
      date&.event&.sale_disabled? && !current_user&.admin?
    end

    def sold_out?
      date&.sold_out? && !admin?
    end
  end
end
