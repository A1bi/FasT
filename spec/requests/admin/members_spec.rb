# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Admin::MembersController' do
  describe 'PATCH #resume_membership_fee_payments' do
    subject do
      patch resume_membership_fee_payments_admin_members_member_path(member)
    end

    let(:member) { create(:member, :membership_fee_payments_paused) }

    before { sign_in(permissions: %i[members_update]) }

    it 'unpauses membership fee payments' do
      expect { subject }
        .to change { member.reload.membership_fee_payments_paused }.to(false)
    end

    it 'redirects to the member details' do
      subject
      expect(response).to redirect_to(admin_members_member_path(member))
    end
  end
end
