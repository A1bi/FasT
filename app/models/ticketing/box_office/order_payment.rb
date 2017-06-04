module Ticketing::BoxOffice
  class OrderPayment < BaseModel
    belongs_to :order, class_name: 'Ticketing::Order'

    def total
      amount
    end
  end
end
