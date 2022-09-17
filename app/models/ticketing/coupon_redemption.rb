# frozen_string_literal: true

module Ticketing
  class CouponRedemption < ApplicationRecord
    belongs_to :order
    belongs_to :coupon
  end
end
