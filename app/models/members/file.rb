class Members::File < BaseModel
  attr_accessible :description, :title, :file
  
  has_attached_file :file
	
	validates_attachment :file, presence: true
end
