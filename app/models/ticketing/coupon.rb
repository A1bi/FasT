# frozen_string_literal: true

module Ticketing
  class Coupon < ApplicationRecord
    include RandomUniqueAttribute
    include Loggable

    has_random_unique_token :code, 6
    has_and_belongs_to_many :reservation_groups,
                            join_table: :ticketing_coupons_reservation_groups
    has_many :redemptions, class_name: 'Ticketing::CouponRedemption',
                           dependent: :destroy
    belongs_to :purchased_with_order, class_name: 'Ticketing::Order',
                                      optional: true
    has_many :orders, through: :redemptions

    before_create :log_created

    class << self
      def valid
        where('free_tickets > 0')
          .where('expires_at IS NULL OR expires_at > ?', Time.current)
      end

      def expired
        where('expires_at < ?', Time.current).or(where('free_tickets < 1'))
      end

      def within_18_months
        where('created_at > ?', 18.months.ago)
      end
    end

    def expired?
      return true if free_tickets < 1 && reservation_groups.count.zero? &&
                     !amount.positive?

      expires_at&.past?
    end

    def redeem
      log(:redeemed)
    end

    private

    def log_created
      log(:created)
    end
  end
end
