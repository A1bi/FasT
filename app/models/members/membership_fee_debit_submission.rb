# frozen_string_literal: true

module Members
  class MembershipFeeDebitSubmission < ApplicationRecord
    has_many :payments, class_name: 'MembershipFeePayment',
                        foreign_key: :debit_submission_id,
                        inverse_of: :debit_submission,
                        dependent: :nullify

    def sum
      payments.sum(:amount)
    end
  end
end
