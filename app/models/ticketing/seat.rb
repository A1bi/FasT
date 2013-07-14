class Ticketing::Seat < ActiveRecord::Base
  attr_accessible :number, :row, :block_id, :position_x, :position_y
	
	belongs_to :block
	has_many :reservations
  has_many :tickets
  
  validates_presence_of :number, on: :create
	
	def available_on_date?(date)
    tickets.where(date_id: date).empty? && reservations.where(date_id: date).empty?
	end
  
  def reserved_on_date?(date)
    !reservations.where(date_id: date).empty?
  end
  
  def booked_on_date?(date)
    !tickets.where(date_id: date).empty?
  end
  
  def taken?
    taken == 1
  end
  
  def reserved?
    reserved == 1
  end
  
  def available?
    !taken? && !reserved?
  end
  
  def self.with_availability_on_date(date)
    select("ticketing_seats.*, COUNT(ticketing_tickets.id) > 0 AS taken, COUNT(ticketing_reservations.id) > 0 AS reserved")
    .joins("LEFT JOIN ticketing_tickets ON ticketing_tickets.seat_id = ticketing_seats.id AND ticketing_tickets.date_id = #{date.id}")
    .joins("LEFT JOIN ticketing_reservations ON ticketing_reservations.seat_id = ticketing_seats.id AND ticketing_reservations.date_id = #{date.id}")
    .group("ticketing_seats.id")
  end
end
