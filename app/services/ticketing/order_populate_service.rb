# frozen_string_literal: true

module Ticketing
  class OrderPopulateService < BaseService
    def initialize(order, params, current_user: nil)
      super(current_user, params)

      @order = order
    end

    def execute
      update_balance do
        create_items
        redeem_coupons(credit: false)
      end

      redeem_coupons(free_tickets: false)
    end

    private

    def create_items
      TicketCreateService.new(@order, date, current_user, params).execute
      CouponCreateService.new(@order, current_user, order_params).execute
    end

    def redeem_coupons(options)
      coupon_redeem_service.execute(**options)
    end

    def coupon_redeem_service
      @coupon_redeem_service ||=
        CouponRedeemService.new(@order, date, current_user, order_params)
    end

    def update_balance(&block)
      service = OrderBillingService.new(@order)
      service.update_balance(:order_created, &block)
      service.settle_balance_with_retail_account
    end

    def order_params
      params[:order]
    end

    def date
      return if order_params[:date].blank?

      @date ||= EventDate.find(order_params[:date])
    end
  end
end
