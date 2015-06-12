module Ticketing
  class CouponRedemption < BaseModel
    belongs_to :order, required: true
    belongs_to :coupon, required: true, touch: true, autosave: true
  end
end
