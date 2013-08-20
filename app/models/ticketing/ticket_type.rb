class Ticketing::TicketType < BaseModel
  attr_accessible :name, :price, :info
	
	has_many :tickets, :foreign_key => "type_id"
  
  def price
    self[:price] || 0
  end
  
  def self.exclusive(e = true)
    where(exclusive: !!e)
  end
end
