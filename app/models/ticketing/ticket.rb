module Ticketing
  class Ticket < ActiveRecord::Base
  	include Cancellable, RandomUniqueAttribute
	
  	belongs_to :bunch
  	belongs_to :type, :class_name => TicketType
    belongs_to :seat
  	belongs_to :date, :class_name => EventDate
    has_random_unique_number :number, 6
    has_one :passbook_pass, :class_name => Passbook::Records::Pass, :as => :assignable, :dependent => :destroy
	
  	validates_presence_of :type, :seat, :date
    validate :check_reserved
    
    after_save :update_price
    after_save :create_passbook_pass
  
    def seat=(seat)
      @check_reserved = true
      super seat
    end
  
    def date=(date)
      @check_reserved = true
      super date
    end
    
    def price
      self[:price] || 0
    end
  
    private
  
    def check_reserved
      if @check_reserved && seat.taken?(date)
        errors.add :seat, "seat not available"
      end
    end
    
    def update_price
      self[:price] = type.price
    end
    
    def create_passbook_pass
      pass = ::Passbook::Pass.new(date.event.identifier, { ticket: self }, self)
      pass.create
    end
  end
end