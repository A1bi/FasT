class Members::File < BaseModel
  attr_accessible :description, :path, :title
	
	validates_presence_of :path
end
