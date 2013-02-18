class Tickets::Seat < ActiveRecord::Base
  attr_accessible :number, :row, :position_x, :position_y
	
	belongs_to :block
	has_many :reservations
	
	def self.includes_reserved_on_date(date)
		select("tickets_seats.*, COUNT(tickets_reservations.id) > 0 AS reserved")
		.joins("LEFT JOIN tickets_reservations ON tickets_reservations.seat_id = tickets_seats.id AND tickets_reservations.date_id = " + sanitize(date))
		.group("tickets_seats.id")
	end
	
	def reserved
		nil if (self[:reserved].nil?)
		self[:reserved] == 1
	end
	
	def available_on_date?(date)
		self.reservations.where(date_id: date).count < 1
	end
	
	def reserve_on_date(date)
		return false unless self.available_on_date?(date)
		
		Tickets::Reservation.create({ date: date, seat: self }, without_protection: true)
	end
end
