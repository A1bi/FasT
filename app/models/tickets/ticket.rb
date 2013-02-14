class Tickets::Ticket < ActiveRecord::Base
	include Cancellable
	
	belongs_to :bunch
	belongs_to :type, :class_name => Tickets::TicketType
	belongs_to :reservation
	
	def date
		self.reservation.date
	end
	
	def seat
		self.reservation.seat
	end
	
	def type=(type)
    super
		self.price = type.price
  end
end
