class Ticketing::Event < ActiveRecord::Base
  attr_accessible :name
	
	has_many :dates, :class_name => Ticketing::EventDate
  
  def self.by_identifier(id)
    where(identifier: id).first
  end
  
  def self.current
    last
  end
end
