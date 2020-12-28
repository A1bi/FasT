# frozen_string_literal: true

module Members
  class MembershipFeeMailer < ApplicationMailer
    def debit_submission(submission)
      @submission = submission
      attachments["submission_#{submission.id}.xml"] = sepa_xml
      mail to: Settings.members.membership_fee_debit_submission_email
    end

    private

    def sepa_xml
      MembershipFeeDebitSepaXmlService.new(submission: @submission).xml
    end
  end
end
