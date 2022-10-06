# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::Ticket do
  describe '#customer_cancellable?' do
    subject { ticket.customer_cancellable? }

    let(:order) { create(:order, :with_tickets) }
    let(:ticket) { order.tickets.first }
    let(:date) { ticket.date }
    let(:travel_to_date) { Time.current }

    around do |example|
      travel_to(travel_to_date) do
        example.run
      end
    end

    context 'when cancellation period is not yet over' do
      it { is_expected.to be_truthy }
    end

    context 'when cancellation period is over' do
      let(:travel_to_date) { date.date - described_class::CANCELLABLE_UNTIL_BEFORE_DATE + 1.hour }

      it { is_expected.to be_falsy }

      context 'when date is cancelled' do
        before { date.update(cancellation: create(:cancellation)) }

        it { is_expected.to be_truthy }
      end
    end

    context 'when date is cancelled but refund period is over' do
      let(:travel_to_date) { date.date + described_class::REFUNDABLE_FOR_AFTER_DATE + 1.day }

      before { date.update(cancellation: create(:cancellation)) }

      it { is_expected.to be_falsy }
    end

    context 'when ticket is already cancelled' do
      before { create(:cancellation, tickets: [ticket]) }

      it { is_expected.to be_falsy }
    end
  end
end
