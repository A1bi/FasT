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
          order.purchased_coupons.new(amount: coupon_params[:amount])
        end
      end
    end
  end
end
