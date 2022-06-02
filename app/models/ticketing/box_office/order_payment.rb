# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class OrderPayment < ApplicationRecord
      belongs_to :order, class_name: 'Ticketing::Order'

      def total
        amount
      end

      def vat_rate
        return order.tickets.first.vat_rate if order.tickets.any?

        :zero
      end
    end
  end
end
