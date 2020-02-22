# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def enum(definitions)
      return super if definitions.delete(:integer_column)

      super(definitions.transform_values do |values|
        next values unless values.is_a? Array

        Hash[values.map { |val| [val, val.to_s] }]
      end)
    end
  end
end
