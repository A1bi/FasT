# frozen_string_literal: true

module Members
  class SubmitMembershipFeeDebitsJob < ApplicationJob
    def perform
      return unless Settings.ebics.enabled

      payments.transaction do
        payments.lock!
        next if payments.none?

        submission = MembershipFeeDebitSubmission.create!(payments:)
        xml = MembershipFeeDebitSepaXmlService.new(submission).xml
        response = ebics_service.submit_debits(xml)

        # reaching this line means debits have been successfully submitted to the bank,
        # suppress any possible errors from here so the database transaction is committed and
        # therefore this job will not run again with these payments and they will not be submitted again
        suppress_in_production(StandardError) do
          submission.update(ebics_response: response)
        end
      end
    end

    private

    def payments
      @payments ||= MembershipFeePayment.submittable
    end

    def ebics_service
      @ebics_service ||= Ticketing::EbicsService.new
    end
  end
end
