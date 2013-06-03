module Ticketing
  class ReservationGroup < ActiveRecord::Base
    attr_accessible :name
    
    has_many :reservations
  
    validates_presence_of :name
  end
end