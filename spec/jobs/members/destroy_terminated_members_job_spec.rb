# frozen_string_literal: true

require 'support/time'

RSpec.describe Members::DestroyTerminatedMembersJob do
  let!(:terminated_member1) do
    create(:member, membership_terminates_on: 3.days.from_now)
  end
  let!(:terminated_member2) do
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
      let(:travel_to_date) { 4.days.from_now }

      it 'destroys one members' do
        expect { subject }.to change(Members::Member, :count).by(-1)
      end

      it 'destroys the correct member' do
        subject
        expect { terminated_member1.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when two memberships have expired' do
      let(:travel_to_date) { 6.days.from_now }

      it 'destroys one members' do
        expect { subject }.to change(Members::Member, :count).by(-2)
      end

      it 'destroys the correct member' do
        subject
        [terminated_member1, terminated_member2].each do |member|
          expect { member.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
