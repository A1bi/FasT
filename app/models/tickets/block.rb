class Tickets::Block < ActiveRecord::Base
  attr_accessible :name
	
	has_many :seats
end
