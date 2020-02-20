module Members
  class MembershipFeePayment < ApplicationRecord
    belongs_to :member
    belongs_to :debit_submission, optional: true

    validates :amount, numericality: { greater_than: 0 }

    class << self
      def unsubmitted
        where(debit_submission_id: nil)
      end

      def submit!
        MembershipFeeDebitSubmission.create(payments: all)
      end
    end
  end
end
