module Ticketing
  class OrderSearchService < BaseService
    def initialize(query, retail_store: nil)
      @query = query
      @retail_store = retail_store
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

      order = search_base.find_by(number: order_number)
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

      search_base.where(matches).order(:last_name, :first_name)
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

    def search_base
      @retail_store ? @retail_store.orders : Order
    end
  end
end
