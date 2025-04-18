# frozen_string_literal: true

require 'support/time'

RSpec.describe Members::DestroyTerminatedMembersJob do
  let!(:cancelled_member_3_days) do
    create(:member, membership_terminates_on: 3.days.from_now)
  end
  let!(:cancelled_member_5_days) do
    create(:member, membership_terminates_on: 5.days.from_now)
  end

  before { create_list(:member, 3) }

  describe '#perform_now' do
    subject do
      travel_to(travel_to_date) do
        described_class.perform_now
      end
    end

    context 'when no memberships have expired yet' do
      let(:travel_to_date) { Time.current }

      it 'did not destroy any members' do
        expect { subject }.not_to change(Members::Member, :count)
      end
    end

    context 'when the first membership has expired' do
      let(:travel_to_date) { 4.days.from_now.beginning_of_day }

      it 'destroys one members' do
        expect { subject }.to change(Members::Member, :count).by(-1)
      end

      it 'destroys the correct member' do
        subject
        expect { cancelled_member_3_days.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when two memberships have expired' do
      let(:travel_to_date) { 6.days.from_now.beginning_of_day }

      it 'destroys one members' do
        expect { subject }.to change(Members::Member, :count).by(-2)
      end

      it 'destroys the correct member' do
        subject
        [cancelled_member_3_days, cancelled_member_5_days].each do |member|
          expect { member.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
