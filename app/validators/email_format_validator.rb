# frozen_string_literal: true

class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?

    # don't use URI::MailTo::EMAIL_REGEXP as it doesn't allow non-ascii domains
    return if value.match? FasT::EMAIL_REGEXP

    record.errors.add(attribute, :invalid)
  end
end
