class Ticketing::Event < ActiveRecord::Base
  attr_accessible :name
	
	has_many :dates, :class_name => Ticketing::EventDate
  
  def self.current
    last
  end
end
