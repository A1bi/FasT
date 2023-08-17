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

  describe '#admission_time' do
    subject { date.admission_time }

    let(:event) { build(:event, admission_duration: 42) }
    let(:date) { build(:event_date, event:, date: Time.zone.parse('2021-06-22 20:00')) }

    it { is_expected.to eq(Time.zone.parse('2021-06-22 19:18')) }
  end
end
