module Members
  class MembershipFeeDebitSubmission < ApplicationRecord
    has_many :payments, class_name: 'MembershipFeePayment',
                        foreign_key: :debit_submission_id,
                        inverse_of: :debit_submission,
                        dependent: :nullify

    validates :payments, length: { minimum: 1 }
  end
end
