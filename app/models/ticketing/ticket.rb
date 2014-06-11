module Ticketing
  class Ticket < BaseModel
  	include Cancellable, RandomUniqueAttribute
	
  	belongs_to :order, touch: true
  	belongs_to :type, class_name: TicketType
    belongs_to :seat
  	belongs_to :date, class_name: EventDate
    has_random_unique_number :number, 6
    has_one :passbook_pass, class_name: Passbook::Records::Pass, as: :assignable, dependent: :destroy
    has_many :checkins, class_name: BoxOffice::Checkin
	
  	validates_presence_of :type, :seat, :date
    validate :check_reserved
    
    after_save :create_passbook_pass
  
    def seat=(seat)
      @check_reserved = true
      super seat
    end
  
    def date=(date)
      @check_reserved = true
      super date
    end
    
    def type=(type)
      super
      self[:price] = type.price
    end
    
    def price
      self[:price] || 0
    end
    
    def number
      "7#{self[:number]}"
    end
    
    def can_check_in?
      !checked_in?
    end
    
    def checked_in?
      !!checkins.last.try(:in)
    end
  
    private
  
    def check_reserved
      if @check_reserved && seat.taken?(date)
        errors.add :seat, "seat not available"
      end
    end
    
    def create_passbook_pass
      pass = ::Passbook::Pass.new(date.event.identifier, { ticket: self }, self)
      pass.create
      NodeApi.push_to_app(:passbook, { aps: "" }, passbook_pass.devices.map { |device| device.push_token }) if passbook_pass.devices.any?
    end
  end
end