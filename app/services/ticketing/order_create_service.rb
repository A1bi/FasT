# frozen_string_literal: true

module Ticketing
  class OrderCreateService < BaseService
    class FreeTicketTypeMissingError < StandardError; end

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

      create_tickets
      redeem_coupons

      Covid19AttendeeCreateService.new(params.dig(:covid19, :attendees), @order)
                                  .execute

      finalize_order

      @order
    end

    private

    def validate_event
      if sale_disabled?
        @order.errors.add(:event, 'Ticket sale currently disabled')
      end

      if sale_disabled_for_store?
        @order.errors.add(:store, 'Ticket sale disabled for this retail store')
      end

      @order.errors.add(:date, 'Date is cancelled') if date.cancelled?

      @order.errors.add(:event, 'Sold out') if sold_out?
    end

    def create_tickets
      TicketCreateService.new(@order, date, current_user, params).execute
    end

    def redeem_coupons
      return unless (codes = Array(order_params[:coupon_codes])).any?

      tickets_by_price = @order.tickets.to_a.sort_by(&:price)
      free_ticket_type = date.event.ticket_types.find_by(price: 0)
      raise FreeTicketTypeMissingError if free_ticket_type.nil?

      Ticketing::Coupon.where(code: codes).each do |coupon|
        next if coupon.expired?

        coupon.redeem
        @order.redeemed_coupons << coupon

        redeem_free_tickets(coupon, tickets_by_price)
      end
    end

    def redeem_free_tickets(coupon, tickets_by_price)
      return if order_params[:ignore_free_tickets].present?

      coupon.free_tickets.times do
        break if tickets_by_price.empty?

        tickets_by_price.pop.type = free_ticket_type
        coupon.free_tickets -= 1
      end
    end

    def create_payment
      @order.pay_method = order_params[:payment][:method]
      return unless @order.charge_payment?

      charge_params = order_params[:payment].slice(:name, :iban)
      @order.build_bank_charge(charge_params)
    end

    def finalize_order
      ActiveRecord::Base.transaction do
        contexts = [:create, (:unprivileged_order unless admin?)]
        return unless @order.save(context: contexts)

        update_node_seats
      end

      suppress_in_production(StandardError) do
        send_push_notifications
      end
    end

    def send_push_notifications
      Ticketing::OrderPushNotificationsJob.perform_later(@order, admin: admin?)
    end

    def update_node_seats
      return unless date.event.seating.plan?

      NodeApi.update_seats_from_records(@order.tickets)
    end

    def order_class
      if retail?
        Ticketing::Retail::Order
      elsif box_office?
        Ticketing::BoxOffice::Order
      else
        Ticketing::Web::Order
      end
    end

    def order_params
      params[:order]
    end

    def date
      @date ||= Ticketing::EventDate.find(order_params[:date])
    end

    def sale_disabled?
      date.event.sale_disabled? && !current_user&.admin?
    end

    def sale_disabled_for_store?
      retail? && !@order.store&.sale_enabled?
    end

    def sold_out?
      date.sold_out? && !admin?
    end
  end
end
