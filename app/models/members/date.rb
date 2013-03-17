class Members::Date < ActiveRecord::Base
  attr_accessible :datetime, :info, :location
	
	validates_presence_of :datetime
end
