# frozen_string_literal: true

module Members
  class SubmitMembershipFeeDebitsJob < ApplicationJob
    def perform
      MembershipFeeDebitSubmission.create(payments: unsubmitted_payments)
    end

    private

    def unsubmitted_payments
      MembershipFeePayment.where(debit_submission_id: nil)
    end
  end
end
