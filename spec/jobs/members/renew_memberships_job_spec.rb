# frozen_string_literal: true

RSpec.describe Members::RenewMembershipsJob do
  let!(:new_member) { create(:member) }
  let!(:member_not_due) do
    create(:member, membership_fee_paid_until: 1.week.from_now)
  end
  let!(:member_due) do
    create(:member, membership_fee_paid_until: Date.yesterday)
  end
  let!(:cancelled_member) do
    create(:member, :membership_cancelled,
           membership_fee_paid_until: 1.month.ago)
  end

  describe '#perform_now' do
    subject { described_class.perform_now }

    it 'renews members without a payment yet' do
      expect { subject }
        .to(change { new_member.reload.membership_fee_paid_until })
    end

    it 'renews members due for renewal' do
      expect { subject }
        .to(change { member_due.reload.membership_fee_paid_until })
    end

    it 'does not renew a cancelled member' do
      expect { subject }
        .not_to(change { cancelled_member.reload.membership_fee_paid_until })
    end

    it 'does not renew a member not yet due for renewal' do
      expect { subject }
        .not_to(change { member_not_due.reload.membership_fee_paid_until })
    end

    it 'creates membership fee payments' do
      expect { subject }.to change(Members::MembershipFeePayment, :count).by(2)
    end

    it 'enqueues a debits submission job' do
      expect { subject }
        .to have_enqueued_job(Members::SubmitMembershipFeeDebitsJob)
    end
  end
end
