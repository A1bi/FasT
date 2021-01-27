# frozen_string_literal: true

RSpec.describe Members::Member do
  describe '#renew_membership!' do
    subject { member.renew_membership! }

    shared_examples 'no renewal' do
      it 'does not renew the membership' do
        expect { subject }.not_to change(member, :membership_fee_paid_until)
      end

      it 'does not create a membership fee payment' do
        expect { subject }.not_to change(Members::MembershipFeePayment, :count)
      end
    end

    shared_examples 'renewal' do
      it 'renews the membership' do
        expect { subject }
          .to change(member, :membership_fee_paid_until).to(paid_until)
      end

      it 'does not create a membership fee payment' do
        expect { subject }
          .to change(Members::MembershipFeePayment, :count).by(1)
        payment = member.membership_fee_payments.last
        expect(payment.paid_until).to eq(paid_until)
        expect(payment.amount).to eq(member.membership_fee)
      end
    end

    context 'when membership is cancelled' do
      let(:member) { create(:member, :membership_cancelled) }

      include_examples 'no renewal'
    end

    context 'when membership is not due for renewal' do
      let(:member) { create(:member, :membership_fee_paid) }

      include_examples 'no renewal'
    end

    context 'when no membership fee payment has been made before' do
      let(:member) { create(:member) }
      let(:paid_until) { 6.months.from_now.to_date - 1.day }

      include_examples 'renewal'
    end

    context 'when membership is due for renewal' do
      let(:member) do
        create(:member, membership_fee_paid_until: Time.zone.yesterday)
      end
      let(:paid_until) { Time.zone.yesterday + 6.months }

      include_examples 'renewal'
    end
  end
end
