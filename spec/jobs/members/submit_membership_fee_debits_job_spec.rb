# frozen_string_literal: true

RSpec.describe Members::SubmitMembershipFeeDebitsJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    let(:ebics_enabled) { true }
    let(:ebics_service) { instance_double(Ticketing::EbicsService) }
    let(:debit_xml_service) { instance_double(Members::MembershipFeeDebitSepaXmlService, xml: 'debits') }
    let!(:submitted_payment) { create(:membership_fee_payment, :submitted) }

    before do
      allow(Settings.ebics).to receive(:enabled).and_return(ebics_enabled)
      allow(Ticketing::EbicsService).to receive(:new).and_return(ebics_service)
      allow(ebics_service).to receive_messages(submit_debits: %w[foo bar])
    end

    shared_examples 'does nothing' do
      it 'creates no debit submissions' do
        expect { subject }.not_to change(Members::MembershipFeeDebitSubmission, :count)
      end

      it 'does not submit anything' do
        expect(ebics_service).not_to receive(:submit_debits)
        subject
      end
    end

    context 'with EBICS disabled' do
      let(:ebics_enabled) { false }

      it 'does not fetch payments' do
        expect(Members::MembershipFeePayment).not_to receive(:submittable)
        subject
      end

      include_examples 'does nothing'
    end

    context 'when no submittable payments exist' do
      include_examples 'does nothing'
    end

    context 'when any submittable payments exist' do
      let!(:submittable_payments) { create_list(:membership_fee_payment, 3, :with_sepa_mandate) }

      it 'creates a debit submission' do
        expect { subject }.to change(Members::MembershipFeeDebitSubmission, :count).by(1)
      end

      it 'marks the payments as submitted' do
        expect(submittable_payments.pluck(:debit_submission_id)).to all(be_nil)

        subject
        submittable_payments.each(&:reload)
        submission = Members::MembershipFeeDebitSubmission.last

        expect(submittable_payments.pluck(:debit_submission_id)).to all(eq(submission.id))
      end

      it 'does not resubmit other payments' do
        expect { subject }.not_to(change { submitted_payment.reload.debit_submission_id })
      end

      it 'submits the correct payloads' do
        expect(Members::MembershipFeeDebitSepaXmlService).to receive(:new) do |submission|
          expect(submission.payments).to match_array(submittable_payments)
        end.and_return(debit_xml_service)
        expect(ebics_service).to receive(:submit_debits).with('debits')
        subject
      end

      it 'stores the EBICS responses' do
        subject
        expect(Members::MembershipFeeDebitSubmission.last.ebics_response).to eq(%w[foo bar])
      end

      context 'when job is run twice' do
        before { described_class.perform_now }

        include_examples 'does nothing'
      end
    end

    context 'when creating a submission fails' do
      before do
        create(:membership_fee_payment)
        allow(Members::MembershipFeeDebitSubmission).to receive(:create!).and_raise(StandardError)
      end

      it 'does not submit via EBICS' do
        expect(ebics_service).not_to receive(:submit_debits)
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when EBICS submission fails' do
      before do
        create(:membership_fee_payment)
        allow(ebics_service).to receive(:submit_debits).and_raise(StandardError)
      end

      it 'creates no submissions' do
        expect { subject }.to raise_error(StandardError).and(not_change(Members::MembershipFeeDebitSubmission, :count))
      end
    end

    context 'when an error happens after EBICS submission' do
      let!(:submittable_payments) { create_list(:membership_fee_payment, 2, :with_sepa_mandate) }
      let(:submission) { build(:membership_fee_debit_submission, payments: submittable_payments) }
      let(:exception) { StandardError.new('failed to update submission') }

      before do
        allow(Members::MembershipFeeDebitSubmission).to receive(:create!) do
          submission.save
          submission
        end
        allow(submission).to receive(:update).and_raise(exception)
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end

      it 'still creates a debit submission' do
        expect { subject }.to change(Members::MembershipFeeDebitSubmission, :count).by(1)
      end

      it 'still marks the payments as submitted' do
        subject
        expect(submission.reload.payments).to match_array(submittable_payments)
      end

      it 'captures the error' do
        expect(Sentry).to receive(:capture_exception).with(exception)
        subject
      end
    end
  end
end
