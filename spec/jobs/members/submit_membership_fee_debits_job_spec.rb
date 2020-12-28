# frozen_string_literal: true

RSpec.describe Members::SubmitMembershipFeeDebitsJob do
  let!(:payments_to_submit) { create_list(:membership_fee_payment, 3) }
  let!(:submitted_payment) { create(:membership_fee_payment, :submitted) }

  describe '#perform_now' do
    subject { described_class.perform_now }

    it 'creates a debit submission' do
      expect { subject }
        .to change(Members::MembershipFeeDebitSubmission, :count).by(1)
    end

    it 'marks the payments as submitted' do
      expect(payments_to_submit.pluck(:debit_submission_id)).to all(be_nil)

      subject
      payments_to_submit.each(&:reload)
      submission = Members::MembershipFeeDebitSubmission.last

      expect(payments_to_submit.pluck(:debit_submission_id))
        .to all(eq(submission.id))
    end

    it 'does not resubmit other payments' do
      expect { subject }
        .not_to(change { submitted_payment.reload.debit_submission_id })
    end
  end
end
