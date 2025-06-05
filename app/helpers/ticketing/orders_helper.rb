# frozen_string_literal: true

module Ticketing
  module OrdersHelper
    def max_tickets_for_type(max_tickets, type)
      return max_tickets unless type.exclusive? && !current_user.admin?

      type.credit_left_for_member(current_user)
    end

    def redeemed_coupon_list(order)
      return tag.em(t('application.none')) if order.redeemed_coupons.none?

      safe_join(order.redeemed_coupons.map do |coupon|
        link_to_if(policy(coupon).show?, coupon.recipient.presence || "##{coupon.id}", coupon)
      end, ', ')
    end
  end
end
