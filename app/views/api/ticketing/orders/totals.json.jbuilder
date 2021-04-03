# frozen_string_literal: true

json.total @order.total.to_f
json.total_before_coupons @order.total_before_coupons.to_f
json.total_after_coupons (-@order.balance).to_f

json.redeemed_coupons @order.redeemed_coupons.map(&:code)
