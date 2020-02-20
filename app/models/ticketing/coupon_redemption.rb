module Ticketing
  class CouponRedemption < ApplicationRecord
    belongs_to :order
    belongs_to :coupon, touch: true, autosave: true
  end
end
