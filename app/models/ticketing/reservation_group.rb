module Ticketing
  class ReservationGroup < ActiveRecord::Base
    attr_accessible :name
    
    has_many :reservations, foreign_key: :group_id
  
    validates_presence_of :name
  end
end