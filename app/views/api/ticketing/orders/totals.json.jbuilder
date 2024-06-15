# frozen_string_literal: true

json.call(@result, :subtotal, :total, :total_after_coupons, :free_tickets_discount, :credit_discount)

json.redeemed_coupons @result[:redeemed_coupons].pluck(:code)
