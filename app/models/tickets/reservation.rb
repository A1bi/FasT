class Tickets::Reservation < ActiveRecord::Base
	belongs_to :seat
	belongs_to :date, :class_name => Tickets::EventDate
	has_one :ticket
	
	def set_default_expiration
		self.expires = 5.minutes.from_now
		self.save
	end
	
	def expired?
		return false if self.expires.nil? || self.ticket.nil?
		self.expires < Time.now
	end
end
