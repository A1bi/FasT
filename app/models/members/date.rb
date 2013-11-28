class Members::Date < BaseModel
  attr_accessible :datetime, :info, :location, :title
	
	validates_presence_of :datetime
	
	def self.not_expired
		where("datetime > ?", Time.zone.now - 2.hours)
	end
end
