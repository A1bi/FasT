# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Admin::MembershipFeePaymentsController' do
  describe 'PATCH #mark_as_failed' do
    subject { patch mark_as_failed_admin_members_membership_fee_payment_path(payment) }

    let(:member) { create(:member, :membership_fee_paid) }
    let(:payment) { create(:membership_fee_payment, member:) }

    before { sign_in(permissions: %i[members_update], web_authn: true) }

    it 'marks the payment as failed' do
      expect { subject }.to change { payment.reload.failed }.to(true)
    end

    it 'pauses payments for the corresponding member' do
      expect { subject }.to change { member.reload.membership_fee_payments_paused }.to(true)
    end

    context 'when a previous payment exists' do
      let!(:previous_payment) { create(:membership_fee_payment, member:, paid_until: 2.months.from_now) }

      it "updates the member's paid_until" do
        expect { subject }.to change { member.reload.membership_fee_paid_until }.to(previous_payment.paid_until)
      end
    end

    context 'when a previous payment does not exist' do
      it "removes the member's paid_until" do
        expect { subject }.to change { member.reload.membership_fee_paid_until }.to(nil)
      end
    end

    it 'redirects to the member details' do
      subject
      expect(response).to redirect_to(admin_members_member_path(member))
    end
  end
end
