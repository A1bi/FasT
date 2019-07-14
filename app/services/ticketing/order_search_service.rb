module Ticketing
  class OrderSearchService < BaseService
    def initialize(query)
      @query = query
    end

    def execute
      return [[], nil] if @query.blank?

      order, ticket = order_and_ticket_by_number

      orders = if order.present?
                 [order]
               else
                 orders_by_full_text_search
               end

      [orders, ticket]
    end

    private

    def order_and_ticket_by_number
      order_number, ticket_index = match_number_parts
      return nil if order_number.blank?

      order = Ticketing::Order.find_by(number: order_number)
      return order if ticket_index.blank?

      ticket = order.tickets.find_by(order_index: ticket_index)
      [order, ticket]
    end

    def orders_by_full_text_search
      table = Ticketing::Order.arel_table
      matches = nil

      search_terms.each do |term|
        match = table[:first_name]
                .matches("%#{term}%").or(
                  table[:last_name].matches("%#{term}%")
                )
        matches = matches ? matches.or(match) : match
      end

      Ticketing::Order.where(matches).order(:last_name, :first_name)
    end

    def match_number_parts
      return false unless @query =~ ticket_number_regex

      [Regexp.last_match(1), Regexp.last_match(3)]
    end

    def ticket_number_regex
      max_digits = Ticketing::Order::NUMBER_DIGITS
      Regexp.new(/\A(\d{1,#{max_digits}})(-(\d+))?\z/)
    end

    def search_terms
      ActiveSupport::Inflector.transliterate(@query).split(' ').uniq << @query
    end
  end
end
