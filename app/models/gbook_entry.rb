class GbookEntry < BaseModel
  attr_accessible :author, :text
  
  validates :author, :presence => true
  validates :text, :presence => true
end
