# frozen_string_literal: true

RSpec.describe Members::SubmitMembershipFeeDebitsJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    let!(:submitted_payment) { create(:membership_fee_payment, :submitted) }

    context 'when no unsubmitted payments exist' do
      it 'does not create a debit submission' do
        expect { subject }
          .not_to change(Members::MembershipFeeDebitSubmission, :count)
      end

      it 'does not enqueue any sending' do
        expect { subject }
          .not_to have_enqueued_mail(Members::MembershipFeeMailer)
      end
    end

    context 'when any unsubmitted payments exist' do
      let!(:payments_to_submit) { create_list(:membership_fee_payment, 3) }

      it 'creates a debit submission' do
        expect { subject }.to change(Members::MembershipFeeDebitSubmission, :count).by(1)
      end

      it 'marks the payments as submitted' do
        expect(payments_to_submit.pluck(:debit_submission_id)).to all(be_nil)

        subject
        payments_to_submit.each(&:reload)
        submission = Members::MembershipFeeDebitSubmission.last

        expect(payments_to_submit.pluck(:debit_submission_id)).to all(eq(submission.id))
      end

      it 'does not resubmit other payments' do
        expect { subject }.not_to(change { submitted_payment.reload.debit_submission_id })
      end

      it 'enqueues sending the debit SEPA XML file' do
        expect { subject }.to(
          have_enqueued_mail(Members::MembershipFeeMailer, :debit_submission)
          .with do |args|
            expect(args[:args].first).to eq(Members::MembershipFeeDebitSubmission.last)
          end
        )
      end
    end
  end
end
