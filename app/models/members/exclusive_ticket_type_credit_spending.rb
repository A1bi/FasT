module Members
  class ExclusiveTicketTypeCreditSpending < ApplicationRecord
    belongs_to :member
    belongs_to :ticket_type, class_name: 'Ticketing::TicketType'
    belongs_to :order, class_name: 'Ticketing::Order'

    validates :value, numericality: { greater_than: 0 }
  end
end
