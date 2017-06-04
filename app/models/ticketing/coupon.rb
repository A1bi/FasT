class Ticketing::Coupon < BaseModel
  include RandomUniqueAttribute, Ticketing::Loggable

  has_random_unique_token :code, 6
  has_and_belongs_to_many :reservation_groups, join_table: :ticketing_coupons_reservation_groups
  has_many :redemptions, class_name: 'Ticketing::CouponRedemption', dependent: :destroy
  has_many :orders, through: :redemptions

  before_create :before_create

  def expired?
    return true if free_tickets < 1 && reservation_groups.count.zero?
    return false if expires.nil?
    expires < Time.now
  end

  def self.expired(e = true)
    if e
      where.not(expires: nil).where("expires < ?", Time.now)
    else
      table = self.arel_table
      where(table[:expires].eq(nil).or(table[:expires].gteq(Time.now)))
    end
  end

  def redeem
    log(:redeemed)
  end

  private

  def before_create
    log(:created)
  end
end
