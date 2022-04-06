# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActionView::Helpers::NumberHelper
end

RSpec.describe Members::MembershipFeeMailer do
  describe '#debit_submission' do
    subject(:mail) { described_class.debit_submission(submission) }

    let(:submission) { create(:membership_fee_debit_submission, payments:) }
    let(:payments) { create_list(:membership_fee_payment, 2, :with_sepa_mandate) }
    let(:xml_content) { 'foo' }

    before do
      xml_service = instance_double('Members::MembershipFeeDebitSepaXmlService',
                                    xml: xml_content)
      allow(Members::MembershipFeeDebitSepaXmlService)
        .to receive(:new).with(submission:).and_return(xml_service)
    end

    it 'sends the mail to the configured person' do
      expect(mail.to).to eq([Settings.members.membership_fee_debit_submission_email])
    end

    it 'includes info about the submission in the body' do
      payments.each do |payment|
        expect(mail.text_part.body).to include(payment.member.name.full, number_to_currency(payment.amount))
      end
    end

    it 'attaches the SEPA XML file' do
      expect(mail.attachments.size).to eq(1)
      attachment = mail.attachments[0]
      expect(attachment.filename).to eq("submission_#{submission.id}.xml")
      expect(attachment.content_type).to start_with('application/xml')
      expect(attachment.body).to eq(xml_content)
    end
  end
end
