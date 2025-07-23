# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::EventDate do
  describe '.upcoming' do
    let!(:just_past_date) { create(:event_date, date: Time.zone.parse('2023-07-15 12:00')) }
    let!(:future_date) { create(:event_date, date: Time.zone.parse('2023-08-01')) }

    before do
      create(:event_date, date: Time.zone.parse('2023-07-01 00:00'))
      travel_to Time.zone.parse('2023-07-15 15:00')
    end

    context 'without offset' do
      subject { described_class.upcoming }

      it { is_expected.to contain_exactly(future_date) }
    end

    context 'with 1 day offset' do
      subject { described_class.upcoming(offset: 1.day) }

      it { is_expected.to contain_exactly(just_past_date, future_date) }
    end
  end

  describe '.imminent' do
    subject { described_class.imminent }

    let!(:distant_date) { create(:event_date, date: 20.hours.from_now) }
    let!(:date) { create(:event_date, date: 2.hours.from_now) }

    before { create(:event_date, date: 30.hours.ago) }

    it { is_expected.to eq(date) }

    context 'with an imminent date slightly in the past' do
      let(:date) { create(:event_date, date: 1.hour.ago) }

      it { is_expected.to eq(date) }
    end

    context 'when the date is long past but still the closest' do
      subject do
        travel_to(16.hours.from_now) { super() }
      end

      it { is_expected.to eq(distant_date) }
    end

    context 'when we are closer to the next date' do
      subject do
        travel_to(6.hours.from_now) { super() }
      end

      it { is_expected.to eq(date) }
    end

    context 'without any dates upcoming' do
      let(:date) { nil }
      let(:distant_date) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#admission_time' do
    subject { date.admission_time }

    let(:event) { build(:event, admission_duration: 42) }
    let(:date) { build(:event_date, event:, date: Time.zone.parse('2021-06-22 20:00')) }

    it { is_expected.to eq(Time.zone.parse('2021-06-22 19:18')) }
  end

  describe '#sold_out?' do
    subject { date.sold_out? }

    let(:date) { event.dates.first }
    let!(:order) { create(:retail_order, :with_tickets, tickets_count:, event:, date:) }

    context 'when date is in the past' do
      let(:event) { create(:event, :complete, number_of_seats: 5, dates_count: 1) }

      before { date.update(date: 1.day.ago) }

      context 'when above threshold' do
        let(:tickets_count) { 5 }

        it { is_expected.to be_truthy }
      end

      context 'when below threshold' do
        let(:tickets_count) { 4 }

        it { is_expected.to be_falsy }
      end
    end

    context 'when date is in the future' do
      before { date.update(date: 1.day.from_now) }

      context 'with seating' do
        let(:event) { create(:event, :complete, :with_seating, seats_count: 5, dates_count: 1) }
        let(:tickets_count) { 5 }

        it { is_expected.to be_truthy }

        context 'when resale allows for more tickets to be sold' do
          before { order.tickets.last.update(resale: true) }

          it { is_expected.to be_falsy }
        end

        context 'when cancellation allows for more tickets to be sold' do
          before { create(:cancellation, tickets: [order.tickets.last]) }

          it { is_expected.to be_falsy }
        end
      end
    end
  end

  shared_context 'with mixed tickets' do
    let(:event) { create(:event, :complete, dates_count: 2) }
    let(:date) { event.dates.last }

    before do
      create(:order, :with_tickets, event:, date:, tickets_count: 2)
      create(:order, :with_tickets, event:, date: event.dates.first, tickets_count: 2)
      order = create(:order, :with_tickets, event:, date:, tickets_count: 4)
      order.tickets[2].update(resale: true)
      cancellation = create(:cancellation)
      order.tickets[3].update(cancellation:)
    end
  end

  describe '#number_of_sold_tickets' do
    subject { date.number_of_sold_tickets }

    include_context 'with mixed tickets'

    it { is_expected.to eq(5) }
  end

  describe '#number_of_valid_tickets' do
    subject { date.number_of_valid_tickets }

    include_context 'with mixed tickets'

    it { is_expected.to eq(4) }
  end

  describe '#number_of_available_seats' do
    subject { date.number_of_available_seats }

    let(:event) { create(:event, :complete, number_of_seats: 15) }
    let(:date) { event.dates.first }

    context 'without any booked seats' do
      it { is_expected.to eq(15) }
    end

    context 'with booked seats' do
      before { create(:order, :with_tickets, event:, date:, tickets_count: 2) }

      it { is_expected.to eq(13) }
    end

    context 'with tickets open for resale' do
      before do
        order = create(:order, :with_tickets, event:, date:, tickets_count: 2)
        order.tickets.last.update(resale: true)
      end

      it { is_expected.to eq(14) }
    end
  end
end
