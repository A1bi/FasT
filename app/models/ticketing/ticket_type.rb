class Ticketing::TicketType < BaseModel
  has_many :tickets, :foreign_key => "type_id"
  belongs_to :event
  has_one :exclusive_ticket_type_credit, class_name: 'Members::ExclusiveTicketTypeCredit', dependent: :destroy

  validates :event, presence: true

  def price
    self[:price] || 0
  end

  def self.exclusive(exclusive)
    where(exclusive: exclusive)
  end

  def credit_left_for_member(member)
    return 0 if member&.id.nil?
    credit = exclusive_ticket_type_credit
    return 0 if credit.nil?
    credit.credit_left_for_member(member)
  end
end
