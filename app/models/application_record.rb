# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def enum(definitions)
      return super if definitions.delete(:integer_column)

      super(definitions.transform_values do |values|
        next values unless values.is_a? Array

        values.index_with(&:to_s)
      end)
    end

    def human_enum_name(name, value)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}" \
             ".#{name.to_s.pluralize}.#{value}")
    end
  end
end
