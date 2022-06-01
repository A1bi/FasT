# frozen_string_literal: true

module Ticketing
  module HasVatRate
    extend ActiveSupport::Concern

    included do
      enum :vat_rate, %i[standard reduced zero], suffix: true
    end
  end
end
