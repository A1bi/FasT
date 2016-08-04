class Ticketing::TicketType < BaseModel
  has_many :tickets, :foreign_key => "type_id"

  def price
    self[:price] || 0
  end

  def self.exclusive(e = true)
    where(exclusive: !!e)
  end
end
