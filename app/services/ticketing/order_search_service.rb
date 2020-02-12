module Ticketing
  class OrderSearchService < BaseService
    def initialize(query, scope: nil)
      @query = query
      @scope = scope
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

      order = scope.find_by(number: order_number)
      return order if ticket_index.blank?

      ticket = order.tickets.find_by(order_index: ticket_index) if order
      [order, ticket]
    end

    def orders_by_full_text_search
      table = Order.arel_table
      matches = nil

      search_words.each do |word|
        %i[first_name last_name affiliation].each do |column|
          term = table[column].matches("%#{word}%")
          matches = matches ? matches.or(term) : term
        end
      end

      scope.where(matches).order(:last_name, :first_name)
    end

    def match_number_parts
      return false unless @query =~ ticket_number_regex

      [Regexp.last_match(1), Regexp.last_match(3)]
    end

    def ticket_number_regex
      max_digits = Order::NUMBER_DIGITS
      Regexp.new(/\A(\d{1,#{max_digits}})(-(\d+))?\z/)
    end

    def search_words
      ActiveSupport::Inflector.transliterate(@query).split(' ').uniq << @query
    end

    def scope
      @scope ||= Order
    end
  end
end
