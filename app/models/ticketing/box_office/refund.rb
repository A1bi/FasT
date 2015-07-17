module Ticketing::BoxOffice
  class Refund < BaseModel
    belongs_to :order, class_name: Ticketing::Order
    
    def total
      -amount
    end
  end
end