module Ticketing
  class OrderBinary < BinData::Record
    bit16 :id

    def self.from_order(order)
      unless order.is_a?(Ticketing::Order)
        raise 'order must be an instance of Ticketing::Order'
      end

      new(
        id: order.id
      )
    end
  end
end
