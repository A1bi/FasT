class Tickets::EventDate < ActiveRecord::Base
  attr_accessible :date
	
	belongs_to :event
	has_many :reservations, :foreign_key => "date_id"
end
