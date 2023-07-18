# frozen_string_literal: true

module Ticketing
  class CouponSearchService < SearchService
    def execute
      return [] if @query.blank?

      coupon = coupon_by_code
      return [coupon] if coupon.present?

      records_by_full_text_search(Coupon, %i[recipient affiliation], recipient: :asc, created_at: :desc)
    end

    private

    def coupon_by_code
      scope.find_by(code: @query)
    end
  end
end
