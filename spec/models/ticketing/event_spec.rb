# frozen_string_literal: true

RSpec.describe Ticketing::Event do
  describe '.with_future_dates' do
    subject { described_class.with_future_dates }

    let(:event) { create(:event, :with_dates, dates_count: 2) }
    let(:cancelled_event) { create(:event, :with_dates, dates_count: 2) }
    let(:partially_cancelled_event) { create(:event, :with_dates, dates_count: 2) }
    let(:past_event) { create(:event, :with_dates, dates_count: 2) }
    let(:cancellation) { create(:cancellation) }

    before do
      event.dates.first.update(date: 1.day.ago)
      cancelled_event.dates.each { |d| d.update(cancellation:) }
      partially_cancelled_event.dates.first.update(cancellation:)
      past_event.dates.each { |d| d.update(date: 1.day.ago) }
    end

    it { is_expected.to contain_exactly(event, partially_cancelled_event) }
  end

  describe '.ordered_by_dates' do
    subject { described_class.ordered_by_dates }

    let(:events) { create_list(:event, 3, :with_dates, dates_count: 1) }

    before do
      events[0].dates.first.update(date: 2.days.ago)
      events[1].dates.first.update(date: 3.days.ago)
      events[2].dates.first.update(date: 1.day.ago)
    end

    context 'without asc/desc' do
      it { is_expected.to contain_exactly(events[2], events[0], events[1]) }
    end

    context 'with desc' do
      subject { described_class.ordered_by_dates(:desc) }

      it { is_expected.to contain_exactly(events[1], events[0], events[2]) }
    end
  end
end
