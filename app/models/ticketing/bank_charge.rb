module Ticketing
  class BankCharge < BaseModel
    belongs_to :submission, class_name: 'BankSubmission', optional: true
    belongs_to :chargeable, polymorphic: true, autosave: true

    auto_strip_attributes :name, squish: true
    auto_strip_attributes :iban, delete_whitespaces: true

    validates_presence_of :name
    validates :amount, numericality: { greater_than: 0 }, if: Proc.new { |c| c.submission.present? }
    validates_with SEPA::IBANValidator

    def mandate_id
      id
    end

    def amount=(val)
      return if submission.present?
      super
    end

    def submitted?
      submission.present?
    end
  end
end
