# frozen_string_literal: true

module Ticketing
  class CouponCreateService < BaseService
    attr_accessor :order

    def initialize(order, current_user, params)
      super current_user, params

      @order = order
    end

    def execute
      return if params[:coupons].blank?

      params[:coupons].each do |coupon_params|
        coupon_params[:number].times do
          coupon = build_coupon(order, coupon_params[:amount])
          log_coupon_creation(coupon)
        end
      end
    end

    private

    def build_coupon(order, amount)
      order.purchased_coupons.new(amount: amount)
    end

    def log_coupon_creation(coupon)
      LogEventCreateService.new(coupon, current_user: current_user).create
    end
  end
end
