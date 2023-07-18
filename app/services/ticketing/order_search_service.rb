# frozen_string_literal: true

module Ticketing
  class OrderSearchService < SearchService
    def execute
      return [[], nil] if @query.blank?

      order, ticket = order_and_ticket_by_number

      orders = if order.present?
                 [order]
               else
                 records_by_full_text_search(Order, %i[first_name last_name affiliation], %i[last_name first_name])
               end

      [orders, ticket]
    end

    private

    def order_and_ticket_by_number
      order_number, ticket_index = match_number_parts
      return nil if order_number.blank?

      order = scope.find_by(number: order_number)
      return order if ticket_index.blank?

      ticket = order.tickets.find_by(order_index: ticket_index) if order
      [order, ticket]
    end

    def match_number_parts
      return false unless @query =~ ticket_number_regex

      [Regexp.last_match(1), Regexp.last_match(3)]
    end

    def ticket_number_regex
      max_digits = Order::NUMBER_DIGITS
      /\A(\d{1,#{max_digits}})(-(\d+))?\z/
    end
  end
end
