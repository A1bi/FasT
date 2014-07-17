module Ticketing
  class Ticket < BaseModel
  	include Cancellable, RandomUniqueAttribute
	
  	belongs_to :order, touch: true
  	belongs_to :type, class_name: TicketType
    belongs_to :seat
  	belongs_to :date, class_name: EventDate
    has_random_unique_number :number, 6
    has_passbook_pass
    has_many :checkins, class_name: BoxOffice::Checkin
	
  	validates_presence_of :type, :seat, :date
    validate :check_reserved
  
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
    
    def update_passbook_pass
      super(date.event.identifier, { ticket: self })
      NodeApi.push_to_app(:passbook, { aps: "" }, passbook_pass.devices.map { |device| device.push_token })
    end
    
    def api_hash
      {
        id: id.to_s,
        number: number.to_s,
        date_id: date.id.to_s,
        type_id: type_id.to_s,
        price: price,
        paid: paid,
        seat_id: seat.id.to_s
      }.merge(super)
    end
  
    private
  
    def check_reserved
      if @check_reserved && seat.taken?(date)
        errors.add :seat, "seat not available"
      end
    end
  end
end