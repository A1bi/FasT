# frozen_string_literal: true

module Members
  class MembershipFeePayment < ApplicationRecord
    belongs_to :member
    belongs_to :debit_submission, class_name: 'MembershipFeeDebitSubmission', optional: true

    validates :amount, numericality: { greater_than: 0 }
  end
end
