# frozen_string_literal: true

RSpec.describe Ticketing::EventDate do
  describe '#admission_time' do
    subject { date.admission_time }

    let(:event) { build(:event, admission_duration: 42) }
    let(:date) { build(:event_date, event: event, date: Time.zone.parse('2021-06-22 20:00')) }

    it { is_expected.to eq(Time.zone.parse('2021-06-22 19:18')) }
  end

  describe '#covid19_check_in_url' do
    subject { date.covid19_check_in_url }

    let(:event) { create(:event, covid19: covid19, admission_duration: 33) }
    let(:date) do
      create(:event_date, event: event, date: Time.zone.parse('2021-05-12 20:00'),
                          covid19_check_in_url: check_in_url)
    end
    let(:check_in_url) { nil }

    shared_examples 'does not create a new URL' do
      it 'does not create a new check-in URL' do
        expect(CoronaPresenceTracing::CWACheckIn).not_to receive(:new)
        subject
      end
    end

    context 'with a COVID-19 event' do
      let(:covid19) { true }

      context 'when check-in URL has not been generated and saved yet' do
        before do
          check_in = instance_double('CoronaPresenceTracing::CWACheckIn', url: 'https://barfoo')
          allow(CoronaPresenceTracing::CWACheckIn).to receive(:new).and_return(check_in)
        end

        it 'creates a new check-in URL' do
          expect(CoronaPresenceTracing::CWACheckIn).to receive(:new).with(
            description: event.name,
            address: event.location.address,
            start_time: Time.zone.parse('2021-05-12 19:27'),
            end_time: Time.zone.parse('2021-05-12 22:00'),
            location_type: :temporary_cultural_event,
            default_check_in_length: 120
          ).and_call_original
          subject
        end

        it 'returns the generated check-in URL' do
          expect(subject).to eq('https://barfoo')
        end

        it 'saves the check-in URL' do
          expect(date[:covid19_check_in_url]).to eq('https://barfoo')
        end
      end

      context 'when check-in URL has already been generated and saved' do
        let(:check_in_url) { 'https://foo' }

        include_examples 'does not create a new URL'

        it 'returns the saved check-in URL' do
          expect(subject).to eq('https://foo')
        end
      end
    end

    context 'with a non-COVID-19 event' do
      let(:covid19) { false }

      it { is_expected.to be_nil }

      include_examples 'does not create a new URL'
    end
  end
end
