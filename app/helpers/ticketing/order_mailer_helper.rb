# frozen_string_literal: true

module Ticketing
  module OrderMailerHelper
    def order_with_number(order)
      text = t('ticketing.order_mailer.order_with_number_html', number: order.number)
      text = strip_tags(text) unless formats.include?(:html)
      text
    end

    def order_balance(order)
      number_to_currency(-order.balance)
    end
  end
end
