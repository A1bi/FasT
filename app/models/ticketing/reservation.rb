class Ticketing::Reservation < ActiveRecord::Base
	belongs_to :seat
	belongs_to :date, :class_name => Ticketing::EventDate
	
	validates_presence_of :seat, :date
	
	def expired?
		return false if self.expires.nil?
		self.expires < Time.now
	end
end
