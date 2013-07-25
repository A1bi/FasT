class Ticketing::CouponTicketTypeAssignment < ActiveRecord::Base
  attr_accessible :number
  
  belongs_to :coupon
  belongs_to :ticket_type
  
  validates_presence_of :coupon, :ticket_type
  
  def unlimited?
    number < 0
  end
end
