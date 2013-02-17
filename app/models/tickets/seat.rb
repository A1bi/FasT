class Tickets::Seat < ActiveRecord::Base
  attr_accessible :number, :row, :position_x, :position_y
	
	belongs_to :block
	has_many :reservations
	
	def available_on_date?(date)
		self.reservations.where(date_id: date).count < 1
	end
	
	def reserve_on_date(date)
		return false unless self.available_on_date?(date)
		
		Tickets::Reservation.create({ date: date, seat: self }, without_protection: true)
	end
end
