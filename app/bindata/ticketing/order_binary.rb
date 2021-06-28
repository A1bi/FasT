# frozen_string_literal: true

module Ticketing
  class OrderBinary < BinData::Record
    bit16 :id

    def self.from_order(order)
      raise 'order must be an instance of Ticketing::Order' unless order.is_a?(Ticketing::Order)

      new(
        id: order.id
      )
    end
  end
end
