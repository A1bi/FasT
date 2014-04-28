class GbookEntry < BaseModel
  validates :author, :presence => true
  validates :text, :presence => true
end
