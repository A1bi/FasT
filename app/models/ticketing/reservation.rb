module Ticketing
  class Reservation < ActiveRecord::Base
    belongs_to :seat
    belongs_to :date, :class_name => EventDate
    belongs_to :group, :class_name => ReservationGroup
  
    validates_presence_of :seat, :date
  
    def expired?
      return false if self.expires.nil?
      self.expires < Time.now
    end
  end
end
