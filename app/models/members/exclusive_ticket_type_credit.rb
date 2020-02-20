module Members
  class ExclusiveTicketTypeCredit < ApplicationRecord
    belongs_to :ticket_type, class_name: 'Ticketing::TicketType'

    validates :ticket_type, uniqueness: true

    def spendings
      ExclusiveTicketTypeCreditSpending.where(ticket_type: ticket_type)
    end

    def credit_left_for_member(member)
      return 0 if value.zero? || member&.id.nil?

      members = member.in_family? ? member.family.members : [member]
      remaining = value * members.count
      spent = spendings.where(member: members).sum(:value)
      remaining -= spent
      [0, remaining].max
    end
  end
end
