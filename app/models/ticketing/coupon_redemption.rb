module Ticketing
  class CouponRedemption < BaseModel
    belongs_to :order
    belongs_to :coupon, touch: true, autosave: true
  end
end
