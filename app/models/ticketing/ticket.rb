module Ticketing
  class Ticket < ActiveRecord::Base
  	include Cancellable, RandomUniqueID
	
  	belongs_to :bunch
  	belongs_to :type, :class_name => TicketType
    belongs_to :seat
  	belongs_to :date, :class_name => EventDate
    has_random_unique_id :number, 6
	
  	validates_presence_of :type, :seat, :date
    validate :check_reserved
	
  	def type=(type)
      super
  		self.price = self.type.try(:price)
    end
  
    def seat=(seat)
      @check_reserved = true
      super seat
    end
  
    def date=(date)
      @check_reserved = true
      super date
    end
  
    private
  
    def check_reserved
      if @check_reserved && !seat.available_on_date?(date)
        errors.add :seat, "seat not available"
      end
    end
  end
end