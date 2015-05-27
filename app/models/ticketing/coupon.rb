class Ticketing::Coupon < BaseModel
  include RandomUniqueAttribute, Ticketing::Loggable
  
  has_random_unique_token :code, 6
  has_many :ticket_type_assignments,
           class_name: Ticketing::CouponTicketTypeAssignment,
           dependent: :destroy, autosave: true
  has_many :ticket_types, through: :ticket_type_assignments
  has_and_belongs_to_many :reservation_groups, join_table: :ticketing_coupons_reservation_groups
  has_many :orders, after_add: :redeemed

  before_create :before_create

  def expired?
    return true if ticket_type_assignments.sum(:number) == 0 && reservation_groups.count.zero?
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
  
  protected
  
  def redeemed(order)
    log(:redeemed)
  end
  
  private

  def before_create
    log(:created)
  end
end
