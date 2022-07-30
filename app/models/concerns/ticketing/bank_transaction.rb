# frozen_string_literal: true

module Ticketing
  module BankTransaction
    extend ActiveSupport::Concern

    include Anonymizable

    included do
      belongs_to :order

      auto_strip_attributes :name, squish: true
      auto_strip_attributes :iban, delete_whitespaces: true
      is_anonymizable columns: %i[name iban]

      validates :name, presence: true, unless: :anonymized?
      validates :amount, numericality: { greater_than: 0, if: proc { |c| c.submission.present? } }
      validates_with SEPA::IBANValidator, unless: :anonymized?
    end

    def amount=(val)
      # allow changes only it has not been submitted yet
      return if attribute_in_database(:submission_id).present?

      super
    end

    def iban=(val)
      super val.upcase
    end

    def submitted?
      submission.present?
    end
  end
end
