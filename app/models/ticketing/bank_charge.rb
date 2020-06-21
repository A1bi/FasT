# frozen_string_literal: true

module Ticketing
  class BankCharge < ApplicationRecord
    belongs_to :submission, class_name: 'BankSubmission', optional: true
    belongs_to :chargeable, polymorphic: true, autosave: true

    auto_strip_attributes :name, squish: true
    auto_strip_attributes :iban, delete_whitespaces: true

    validates :name, presence: true
    validates :amount, numericality: { greater_than: 0,
                                       if: proc { |c| c.submission.present? } }
    validates_with SEPA::IBANValidator

    def mandate_id
      id
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
