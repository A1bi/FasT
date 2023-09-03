# frozen_string_literal: true

module Members
  class MembershipApplication < ApplicationRecord
    auto_strip_attributes :first_name, :last_name, :street, :city, squish: true

    validates :first_name, :last_name, :gender, presence: true
    validates :plz, plz_format: true
    validates :debtor_name, :iban, presence: true
    validates_with SEPA::IBANValidator
  end
end
