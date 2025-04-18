# frozen_string_literal: true

module Ticketing
  class BankTransaction < ApplicationRecord
    include Anonymizable

    belongs_to :order
    belongs_to :submission, class_name: 'BankSubmission', optional: true

    auto_strip_attributes :name, squish: true
    auto_strip_attributes :iban, delete_whitespaces: true
    is_anonymizable columns: %i[name iban raw_source]

    validates :name, presence: true, unless: :anonymized?
    validates :amount, numericality: { other_than: 0, if: proc { |c| c.submission.present? } }
    validates_with SEPA::IBANValidator, unless: :anonymized?
    validates :submission, absence: true, if: :received?
    validates :raw_source_sha, presence: true, if: :received?

    class << self
      def open
        where(submission: nil, raw_source: nil)
      end

      def submittable
        open.where('amount != 0')
      end

      def received
        where.not(raw_source: nil)
      end

      def transfers
        where('amount < 0')
      end

      def debits
        where('amount > 0')
      end
    end

    def amount=(val)
      # allow changes only it has not been submitted yet
      return if attribute_in_database(:submission_id).present?

      super
    end

    def iban=(val)
      super(val.upcase)
    end

    def submitted?
      submission.present?
    end

    def open?
      !received? && !submitted?
    end

    def raw_source=(source)
      source = source.to_h
      super
      assign_attributes(source.slice('name', 'iban', 'amount'))
    end

    def received?
      raw_source.present?
    end

    def mandate_id
      id
    end

    def anonymizable?
      super && order.anonymized?
    end

    private

    def anonymize_raw_source
      raw_source.except!('sub_fields', 'information', 'iban', 'details', 'name', 'sepa', 'bic')
    end
  end
end
