# frozen_string_literal: true

RSpec.describe Ticketing::Event do
  describe 'ticketing enabled scopes' do
    let!(:event_ticketing_enabled) { create(:event, :complete) }
    let!(:event_ticketing_disabled) { create(:event, :with_dates, :ticketing_disabled) }

    describe 'default scope' do
      subject { described_class.all }

      it 'does not contain events with ticketing disabled' do
        expect(subject).not_to include(event_ticketing_disabled)
      end
    end

    describe '.including_ticketing_disabled' do
      subject { described_class.including_ticketing_disabled }

      it 'contains all events' do
        expect(subject).to include(event_ticketing_enabled, event_ticketing_disabled)
      end
    end
  end

  describe '.with_future_dates' do
    let(:event) { create(:event, :with_dates, dates_count: 2) }
    let(:cancelled_event) { create(:event, :with_dates, dates_count: 2) }
    let(:partially_cancelled_event) { create(:event, :with_dates, dates_count: 2) }
    let(:past_event) { create(:event, :with_dates, dates_count: 2) }
    let(:just_past_event) { create(:event, :with_dates, dates_count: 1) }
    let(:cancellation) { create(:cancellation) }

    before do
      event.dates.first.update(date: 1.day.ago)
      cancelled_event.dates.each { |d| d.update(cancellation:) }
      partially_cancelled_event.dates.first.update(cancellation:)
      past_event.dates.each { |d| d.update(date: 1.day.ago) }
      just_past_event.dates[0].update(date: 12.hours.ago)
    end

    context 'without offset' do
      subject { described_class.with_future_dates }

      it { is_expected.to contain_exactly(event, partially_cancelled_event) }
    end

    context 'with 1 day offset' do
      subject { described_class.with_future_dates(offset: 1.day) }

      it { is_expected.to contain_exactly(event, partially_cancelled_event, just_past_event) }
    end
  end

  describe '.ordered_by_dates' do
    subject { described_class.ordered_by_dates }

    let(:events) { create_list(:event, 3, :with_dates, dates_count: 1) }

    before do
      events[0].dates.first.update(date: 2.days.ago)
      events[1].dates.first.update(date: 3.days.ago)
      events[2].dates.first.update(date: 1.day.ago)
      described_class.where.not(id: events).delete_all
    end

    context 'without asc/desc' do
      it { is_expected.to contain_exactly(events[2], events[0], events[1]) }
    end

    context 'with desc' do
      subject { described_class.ordered_by_dates(:desc) }

      it { is_expected.to contain_exactly(events[1], events[0], events[2]) }
    end
  end

  describe '.archived' do
    subject { described_class.archived }

    let(:future_event) { create(:event, :archived, :with_dates, dates_count: 1) }
    let(:partially_future_event) { create(:event, :archived, :with_dates, dates_count: 2) }
    let(:cancelled_event) { create(:event, :archived, :with_dates, dates_count: 1) }
    let(:partially_cancelled_event) { create(:event, :archived, :with_dates, dates_count: 2) }
    let(:past_event) { create(:event, :archived, :with_dates, dates_count: 1) }
    let(:past_not_archived_event) { create(:event, :with_dates, dates_count: 1) }
    let(:cancellation) { create(:cancellation) }

    before do
      future_event.dates.first.update(date: 1.day.from_now)
      partially_future_event.dates.first.update(date: 1.day.ago)
      partially_future_event.dates.last.update(date: 1.day.from_now)
      cancelled_event.dates.first.update(date: 1.day.from_now, cancellation:)
      partially_cancelled_event.dates.first.update(date: 1.day.ago, cancellation:)
      partially_cancelled_event.dates.last.update(date: 1.day.ago)
      past_event.dates.first.update(date: 1.day.ago)
      past_not_archived_event.dates.first.update(date: 1.day.ago)
    end

    it { is_expected.to contain_exactly(partially_cancelled_event, past_event) }
  end
end
