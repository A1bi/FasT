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
      coupons.each do |coupon|
        next if coupon.expired? || order.redeemed_coupons.include?(coupon) ||
                !redeem_coupon(coupon, free_tickets: free_tickets,
                                       credit: credit)

        order.redeemed_coupons << coupon
        log_redemption(coupon)
      end
    end

    private

    def redeem_coupon(coupon, free_tickets:, credit:)
      return true if free_tickets && redeem_free_tickets(coupon)
      return redeem_credit(coupon) if credit
    end

    def redeem_free_tickets(coupon)
      return if params[:ignore_free_tickets].present? ||
                coupon.free_tickets.zero?

      coupon.free_tickets.times do
        break if tickets_by_price.empty?

        tickets_by_price.pop.type = free_ticket_type
        coupon.free_tickets -= 1
      end

      true
    end

    def redeem_credit(coupon)
      return unless coupon.billing_account.credit?

      order_billing_service.deposit_coupon_credit(coupon)

      true
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
