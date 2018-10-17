class Ticketing::TicketType < BaseModel
  has_many :tickets, :foreign_key => "type_id"
  belongs_to :event

  validates :event, presence: true

  def price
    self[:price] || 0
  end

  def self.exclusive(exclusive)
    where(exclusive: exclusive)
  end
end
