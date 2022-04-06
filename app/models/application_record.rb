# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def enum(name = nil, values = nil, **options)
      raise 'old enum syntax not supported' if name.nil?

      values = values.index_with(&:to_s) unless values.is_a?(Hash) || options.delete(:integer_column)
      super
    end

    def human_enum_name(name, value)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{name.to_s.pluralize}.#{value}")
    end
  end
end
