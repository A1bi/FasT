# frozen_string_literal: true

class PlzFormatValidator < ActiveModel::EachValidator
  PLZ_REGEXP = /\A\d{5}\z/

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return if value.match? PLZ_REGEXP

    record.errors.add(attribute, :invalid)
  end
end
