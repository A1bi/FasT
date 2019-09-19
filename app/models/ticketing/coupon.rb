module Ticketing
  class Coupon < BaseModel
    include RandomUniqueAttribute
    include Loggable

    has_random_unique_token :code, 6
    has_and_belongs_to_many :reservation_groups,
                            join_table: :ticketing_coupons_reservation_groups
    has_many :redemptions, class_name: 'Ticketing::CouponRedemption',
                           dependent: :destroy
    has_many :orders, through: :redemptions

    before_create :before_create

    class << self
      def valid
        where('free_tickets > 0')
          .where('expires IS NULL OR expires > ?', Time.current)
      end

      def expired
        where('expires < ?', Time.current).or(where('free_tickets < 1'))
      end

      def within_18_months
        where('created_at > ?', 18.months.ago)
      end
    end

    def expired?
      return true if free_tickets < 1 && reservation_groups.count.zero?

      expires&.past?
    end

    def redeem
      log(:redeemed)
    end

    private

    def before_create
      log(:created)
    end
  end
end
