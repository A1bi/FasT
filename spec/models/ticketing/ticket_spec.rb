# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::Ticket do
  describe 'validations' do
    subject { build(:ticket, date:) }

    context 'when date is cancelled' do
      let(:date) { create(:event_date, :cancelled) }

      it 'has an error on the date' do
        subject.valid?
        expect(subject.errors).to be_added(:date, 'is cancelled')
      end
    end

    context 'when event ticketing is disabled' do
      let(:event) { create(:event, :with_dates, :ticketing_disabled) }
      let(:date) { event.dates.first }

      it 'has an error on the date' do
        subject.valid?
        expect(subject.errors).to be_added(:date, 'event ticketing is disabled')
      end
    end
  end

  describe 'customer actions' do
    let(:order) { create(:order, :with_tickets) }
    let(:ticket) { order.tickets.first }
    let(:date) { ticket.date }
    let(:travel_to_date) { Time.current }

    before { travel_to(travel_to_date) }

    describe '#customer_cancellable?' do
      subject { ticket.customer_cancellable? }

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

        context 'when ticket is exceptionally cancellable' do
          before { ticket.update(exceptionally_customer_cancellable: true) }

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

        context 'when ticket is exceptionally cancellable' do
          before { ticket.update(exceptionally_customer_cancellable: true) }

          it { is_expected.to be_falsy }
        end
      end
    end

    describe '#customer_transferable?' do
      subject { ticket.customer_transferable? }

      context 'when ticket is cancelled' do
        before { create(:cancellation, tickets: [ticket]) }

        it { is_expected.to be_falsy }
      end

      context "when date's admission time is in the future" do
        it { is_expected.to be_truthy }
      end

      context "when date's admission time is in the past" do
        let(:travel_to_date) { date.admission_time + 1.minute }

        it { is_expected.to be_falsy }

        context 'when date is cancelled' do
          before { date.update(cancellation: create(:cancellation)) }

          context 'when there is another possible future date' do
            before do
              date2 = ticket.date.dup
              date2.update(date: date.date + 1.week, cancellation: nil)
            end

            it { is_expected.to be_truthy }
          end

          context 'when there is no other possible future date' do
            it { is_expected.to be_falsy }
          end
        end

        context 'when ticket is exceptionally cancellable' do
          before { ticket.update(exceptionally_customer_cancellable: true) }

          it { is_expected.to be_truthy }
        end
      end
    end
  end
end
