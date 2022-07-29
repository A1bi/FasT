# frozen_string_literal: true

module Ticketing
  class BankChargeSubmission < ApplicationRecord
    has_many :charges,
             class_name: 'BankCharge', foreign_key: :submission_id,
             dependent: :nullify, inverse_of: :submission

    validates :charges, length: { minimum: 1 }
  end
end
