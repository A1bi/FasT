# frozen_string_literal: true

module Ticketing
  class BankSubmission < ApplicationRecord
    has_many :charges,
             class_name: 'BankCharge', foreign_key: :submission_id,
             dependent: :nullify, inverse_of: :submission, autosave: true,
             after_add: :propagate_submission

    validates :charges, length: { minimum: 1 }

    private

    def propagate_submission(charge)
      charge.chargeable.bank_charge_submitted
    end
  end
end
