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
        submission.update(ebics_response: response)
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
