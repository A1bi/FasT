module Ticketing
  class Reservation < BaseModel
    belongs_to :seat, :touch => true
    belongs_to :date, :class_name => EventDate
    belongs_to :group, :class_name => ReservationGroup, :touch => true
  
    validates_presence_of :seat, :date
  
    def expired?
      return false if self.expires.nil?
      self.expires < Time.now
    end
  end
end
