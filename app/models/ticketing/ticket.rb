module Ticketing
  class Ticket < ActiveRecord::Base
  	include Cancellable, RandomUniqueAttribute
	
  	belongs_to :bunch
  	belongs_to :type, :class_name => TicketType
    belongs_to :seat
  	belongs_to :date, :class_name => EventDate
    has_random_unique_number :number, 6
	
  	validates_presence_of :type, :seat, :date
    validate :check_reserved
    
    after_save :create_passbook_pass
	
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
    
    def price
      self[:price] || 0
    end
    
    def passbook_pass_path(full = false)
      File.join(passbook_path(full), "pass-" + Digest::SHA1.hexdigest(number.to_s) + ".pkpass")
    end
  
    private
  
    def check_reserved
      if @check_reserved && !seat.available_on_date?(date)
        errors.add :seat, "seat not available"
      end
    end
    
    def create_passbook_pass
      FileUtils.mkdir_p(passbook_path(true))
      
      pass = Passbook::Pass.new(date.event.identifier, { ticket: self })
      pass.create(passbook_pass_path(true))
    end
    
    def passbook_path(full = false)
      path = Rails.public_path if full
      File.join(path || "", "/system/passbook")
    end
  end
end