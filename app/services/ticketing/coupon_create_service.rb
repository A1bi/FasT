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
          coupon = build_coupon(order, coupon_params[:value])
          log_coupon_creation(coupon)
        end
      end
    end

    private

    def build_coupon(order, value)
      coupon = order.purchased_coupons.new
      coupon.deposit_into_account(value, :purchased_coupon)
      coupon
    end

    def log_coupon_creation(coupon)
      LogEventCreateService.new(coupon, current_user: current_user).create
    end
  end
end
