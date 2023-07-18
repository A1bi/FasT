# frozen_string_literal: true

module Ticketing
  class SearchService < BaseService
    def initialize(query, scope: nil)
      super
      @query = query
      @scope = scope
    end

    private

    def records_by_full_text_search(model, search_attributes, order_attributes)
      table = model.arel_table
      matches = nil

      search_words.each do |word|
        search_attributes.each do |column|
          term = table[column].matches("%#{word}%")
          matches = matches ? matches.or(term) : term
        end
      end

      scope.where(matches).order(order_attributes)
    end

    def search_words
      ActiveSupport::Inflector.transliterate(@query).split.uniq << @query
    end

    def scope
      @scope ||= Order
    end
  end
end
