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
end
