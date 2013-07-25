class Ticketing::Coupon < ActiveRecord::Base
  include RandomUniqueAttribute
  
  attr_accessible :expires, :recipient, :reservation_group_ids
  
  has_random_unique_token :code, 6
  has_many :ticket_type_assignments, class_name: Ticketing::CouponTicketTypeAssignment, dependent: :destroy
  has_many :ticket_types, through: :ticket_type_assignments
  has_and_belongs_to_many :reservation_groups, join_table: :ticketing_coupons_reservation_groups
  has_many :bunches
  
  def expired?
    return true if ticket_type_assignments.sum(:number) == 0 && reservation_groups.count.zero?
    return false if expires.nil?
    expires < Time.now
  end
end
