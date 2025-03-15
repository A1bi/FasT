# frozen_string_literal: true

module Ticketing
  module Errors
    extend ActiveSupport::Concern

    def errors
      @errors ||= []
    end

    def errors?
      errors.any?
    end

    private

    def add_error(key)
      errors << key
    end

    def add_errors(keys)
      errors.push(*keys)
    end
  end
end
