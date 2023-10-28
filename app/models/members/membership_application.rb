# frozen_string_literal: true

module Members
  class MembershipApplication < ApplicationRecord
    include HasGender

    has_person_name

    belongs_to :member, optional: true

    auto_strip_attributes :first_name, :last_name, :street, :city, squish: true

    validates :first_name, :last_name, :gender, presence: true
    validates :plz, plz_format: true
    validates :debtor_name, :iban, presence: true
    validates_with SEPA::IBANValidator

    class << self
      def open
        where.missing(:member)
      end

      def completed
        where.associated(:member)
      end
    end

    def open?
      member.nil?
    end
  end
end
