# frozen_string_literal: true

module Members
  class SepaMandate < ApplicationRecord
    has_many :members, dependent: :nullify

    auto_strip_attributes :debtor_name, squish: true
    auto_strip_attributes :iban, delete_whitespaces: true

    validates :debtor_name, :iban, :number, :issued_on, presence: true
    validates_with SEPA::IBANValidator
    validates :number, uniqueness: true

    after_initialize :set_number
    before_validation :set_issued_on, on: :create

    def number(prefixed: false)
      return super() unless prefixed

      "FAST.#{super().to_s.rjust(6, '0')}"
    end

    def number=(number)
      number.sub!('FAST.', '') if number.is_a? String
      super(number)
    end

    private

    def set_number
      self.number = (self.class.maximum(:number) || 0) + 1 if number.blank?
    end

    def set_issued_on
      self.issued_on ||= Time.zone.today
    end
  end
end
