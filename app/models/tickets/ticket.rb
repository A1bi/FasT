class Tickets::Ticket < ActiveRecord::Base
	include Tickets::Cancellable
	
	belongs_to :bunch
	belongs_to :type, :class_name => Tickets::TicketType
	belongs_to :reservation, :validate => true
	
	validates_presence_of :type
	validates_presence_of :reservation, :on => :create
	
	def date
		self.reservation.date
	end
	
	def seat
		self.reservation.seat
	end
	
	def type=(type)
    super
		self.price = self.type.try(:price)
  end
end
