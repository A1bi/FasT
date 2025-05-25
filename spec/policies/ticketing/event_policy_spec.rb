# frozen_string_literal: true

RSpec.describe Ticketing::EventPolicy do
  subject { described_class }

  let(:event) { create(:event, :complete, dates_count: 1) }
  let(:user) { build(:user, :with_web_authn, permissions: %i[ticketing_events_update]) }

  permissions :update_seating? do
    context 'without any tickets already present' do
      it 'permits updating the seating' do
        expect(subject).to permit(user, event)
      end
    end

    context 'with tickets already present' do
      before { create(:order, :with_tickets, event:, date: event.dates.first, tickets_count: 1) }

      it 'does not permit updating the seating' do
        expect(subject).not_to permit(user, event)
      end
    end
  end

  describe '#permitted_attributes' do
    subject { described_class.new(user, event).permitted_attributes }

    context 'without any tickets already present' do
      it 'permits updating the seating' do
        expect(subject).to include(:seating_id)
      end
    end

    context 'with tickets already present' do
      before { create(:order, :with_tickets, event:, date: event.dates.first, tickets_count: 1) }

      it 'does not permit updating the seating' do
        expect(subject).not_to include(:seating_id)
      end
    end
  end
end
