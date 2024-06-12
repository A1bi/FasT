# frozen_string_literal: true

module Ticketing
  class OrderSearchService < SearchService
    TICKET_NUMBER_REGEX = /\A(\d{1,#{Order::NUMBER_DIGITS}})(-(\d+))?\z/
    POSTCODE_REGEX = /\A\d{5}\z/

    def execute
      return [[], nil] if @query.blank?

      order, ticket = order_and_ticket_by_number

      orders = if order.present?
                 [order]
               else
                 orders_by_postcode ||
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

    def orders_by_postcode
      return unless @query =~ POSTCODE_REGEX

      scope.where(plz: @query)
    end

    def match_number_parts
      return false unless @query =~ TICKET_NUMBER_REGEX

      [Regexp.last_match(1), Regexp.last_match(3)]
    end
  end
end
