# frozen_string_literal: true

module Ticketing
  module OrderMailerHelper
    def order_balance(order)
      number_to_currency(-order.balance)
    end
  end
end
