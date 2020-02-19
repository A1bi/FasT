class Ticketing::TicketType < BaseModel
  has_many :tickets, foreign_key: :type_id, inverse_of: :type,
                     dependent: :nullify
  belongs_to :event
  has_one :exclusive_ticket_type_credit,
          class_name: 'Members::ExclusiveTicketTypeCredit', dependent: :destroy
  has_many :exclusive_ticket_type_credit_spendings,
           class_name: 'Members::ExclusiveTicketTypeCredit', dependent: :destroy

  enum availability: %i[universal exclusive box_office]

  validates :event, presence: true

  class << self
    def ordered_by_availability_and_price
      order(availability: :asc, price: :desc)
    end

    # create scopes except_exclusive and except_box_office
    %i[exclusive box_office].each do |availability|
      define_method "except_#{availability}" do
        where.not(availability: availability)
      end
    end
  end

  def price
    self[:price] || 0
  end

  def credit_left_for_member(member)
    return 0 if member.blank?

    credit = exclusive_ticket_type_credit
    return 0 if credit.nil?

    credit.credit_left_for_member(member)
  end
end
