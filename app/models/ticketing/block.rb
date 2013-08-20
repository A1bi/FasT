class Ticketing::Block < BaseModel
  attr_accessible :name, :color
	
	has_many :seats, :dependent => :destroy
end
