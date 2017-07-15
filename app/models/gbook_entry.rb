class GbookEntry < BaseModel
  auto_strip_attributes :author, squish: true

  validates_presence_of :text

  def anonymous?
    author.blank?
  end
end
