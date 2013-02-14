class Tickets::Event < ActiveRecord::Base
  attr_accessible :name
	
	has_many :dates, :class_name => Tickets::EventDate
end
