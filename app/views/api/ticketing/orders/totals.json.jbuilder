# frozen_string_literal: true

@result.slice(:subtotal, :total, :total_after_coupons, :free_tickets_discount,
              :credit_discount).each do |key, value|
  json.set! key, value.to_f
end

json.redeemed_coupons @result[:redeemed_coupons].pluck(:code)
