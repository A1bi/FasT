# frozen_string_literal: true

module Ticketing
  class BankTransaction < ApplicationRecord
    include Anonymizable

    has_and_belongs_to_many :orders
    belongs_to :submission, class_name: 'BankSubmission', optional: true

    auto_strip_attributes :name, squish: true
    auto_strip_attributes :iban, delete_whitespaces: true
    is_anonymizable columns: %i[name iban camt_source]

    validates :name, presence: true, unless: :anonymized?
    validates :amount, numericality: { other_than: 0, if: proc { |c| c.submission.present? } }
    validates_with SEPA::IBANValidator, unless: :anonymized?
    validates :submission, absence: true, if: :received?
    validates :raw_source_sha, presence: true, if: :received?

    class << self
      def open
        where(submission: nil, camt_source: nil)
      end

      def submittable
        open.where('amount != 0')
      end

      def received
        where.not(camt_source: nil)
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

    def debit?
      !received? && amount.positive?
    end

    def refund?
      !received? && amount.negative?
    end

    def submitted?
      submission.present?
    end

    def open?
      !received? && !submitted?
    end

    def camt_entry=(entry)
      camt_source = Hash.from_xml(entry.xml_data.to_xml)['Ntry']
      raise 'Empty camt_source received' if camt_source.blank?

      assign_attributes(camt_source:, name: entry.name, iban: entry.iban, amount: entry.amount)
    end

    def received?
      camt_source.present?
    end

    def mandate_id
      id
    end

    def anonymizable?
      super && orders.all?(&:anonymized?)
    end

    private

    def anonymize_camt_source
      camt_source.dig('NtryDtls', 'TxDtls')&.except!('RltdPties', 'RmtInf')
    end
  end
end
