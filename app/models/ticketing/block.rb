class Ticketing::Block < ActiveRecord::Base
  attr_accessible :name, :color
	
	has_many :seats
end
