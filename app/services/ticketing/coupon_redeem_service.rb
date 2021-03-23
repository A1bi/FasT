# frozen_string_literal: true

module Ticketing
  class CouponRedeemService < BaseService
    class FreeTicketTypeMissingError < StandardError; end

    attr_accessor :order, :date

    def initialize(order, date, current_user, params)
      super current_user, params

      @order = order
      @date = date
    end

    def execute(free_tickets: true, credit: true)
      return if coupons.empty?

      coupons.each do |coupon|
        next if coupon.expired?

        order.redeemed_coupons << coupon
        log_redemption(coupon)

        redeem_free_tickets(coupon) if free_tickets
        redeem_credit(coupon) if credit
      end
    end

    private

    def redeem_free_tickets(coupon)
      return if params[:ignore_free_tickets].present?

      coupon.free_tickets.times do
        break if tickets_by_price.empty?

        tickets_by_price.pop.type = free_ticket_type
        coupon.free_tickets -= 1
      end
    end

    def redeem_credit(coupon)
      return unless coupon.billing_account.credit?

      order_billing_service.deposit_coupon_credit(coupon)
    end

    def log_redemption(coupon)
      LogEventCreateService.new(coupon, current_user: current_user).redeem
    end

    def coupons
      return [] if params[:coupon_codes].blank?

      @coupons ||= Ticketing::Coupon.where(code: params[:coupon_codes])
    end

    def free_ticket_type
      @free_ticket_type ||= begin
        type = date.event.ticket_types.find_by(price: 0)
        raise FreeTicketTypeMissingError if type.nil?

        type
      end
    end

    def tickets_by_price
      @tickets_by_price ||= order.tickets.to_a.sort_by(&:price)
    end

    def order_billing_service
      @order_billing_service ||= OrderBillingService.new(order)
    end
  end
end
