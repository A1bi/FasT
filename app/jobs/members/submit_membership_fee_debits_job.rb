# frozen_string_literal: true

module Members
  class SubmitMembershipFeeDebitsJob < ApplicationJob
    def perform
      submission =
        MembershipFeeDebitSubmission.create(payments: unsubmitted_payments)

      Members::MembershipFeeMailer.debit_submission(submission).deliver_later
    end

    private

    def unsubmitted_payments
      MembershipFeePayment.where(debit_submission_id: nil)
    end
  end
end
