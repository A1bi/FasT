# frozen_string_literal: true

RSpec.describe Ticketing::BroadcastTicketsSoldJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    shared_examples 'not broadcasting' do
      it 'broadcasts nothing' do
        expect { subject }.not_to have_broadcasted_to(:ticketing_tickets_sold)
      end
    end

    context 'with imminent date' do
      let(:event) { create(:event, :complete, dates_count: 2) }
      let!(:order) { create(:order, :with_tickets, tickets_count: 3, event:, date: event.dates.first) }
      let!(:order_other_date) { create(:order, :with_tickets, tickets_count: 2, event:, date: event.dates.second) }

      before { event.dates.each.with_index { |date, i| date.update(date: i.hours.from_now) } }

      shared_examples 'sold tickets update broadcaster' do
        it 'broadcasts sold tickets updates' do
          expect { subject }.to(
            have_broadcasted_to(:ticketing_tickets_sold)
              .with(tickets_sold: 3, number_of_seats: event.number_of_seats)
          )
        end
      end

      context 'without tickets provided' do
        it_behaves_like 'sold tickets update broadcaster'
      end

      context 'with tickets from imminent date provided' do
        subject { described_class.perform_now(tickets: order.tickets) }

        it_behaves_like 'sold tickets update broadcaster'
      end

      context 'with tickets from non-imminent date provided' do
        subject { described_class.perform_now(tickets: order_other_date.tickets) }

        it_behaves_like 'not broadcasting'
      end
    end

    context 'without imminent date' do
      it_behaves_like 'not broadcasting'
    end
  end
end
