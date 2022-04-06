# frozen_string_literal: true

module HasGender
  extend ActiveSupport::Concern

  GENDERS = %i[female male diverse].freeze

  included do
    enum :gender, GENDERS

    singleton_class.define_method :genders do
      GENDERS
    end
  end
end
