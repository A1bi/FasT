# frozen_string_literal: true

RSpec.describe Ticketing::BroadcastCheckInsJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    shared_examples 'not broadcasting' do
      it 'broadcasts nothing' do
        expect { subject }.not_to have_broadcasted_to(:ticketing_check_ins)
      end
    end

    context 'with imminent date' do
      let(:event) { create(:event, :complete, dates_count: 2) }
      let(:order) { create(:order, :with_tickets, tickets_count: 2, event:, date: event.dates.first) }
      let(:order_other_date) { create(:order, :with_tickets, tickets_count: 3, event:, date: event.dates.second) }
      let!(:check_ins) { order.tickets.map { |ticket| create(:check_in, ticket:) } }
      let!(:check_ins_other_date) { order_other_date.tickets.map { |ticket| create(:check_in, ticket:) } }

      before do
        event.dates.each.with_index { |date, i| date.update(date: i.hours.from_now) }
        # create duplicate check-ins for a ticket to check if those are only counted once
        create(:check_in, ticket: order.tickets.first)
      end

      shared_examples 'check-in update broadcaster' do
        it 'broadcasts check-in updates' do
          expect { subject }.to(have_broadcasted_to(:ticketing_check_ins).with(check_ins: 2))
        end
      end

      context 'without check-ins provided' do
        it_behaves_like 'check-in update broadcaster'
      end

      context 'with check-ins from imminent date provided' do
        subject { described_class.perform_now(check_ins:) }

        it_behaves_like 'check-in update broadcaster'
      end

      context 'with check-ins from non-imminent date provided' do
        subject { described_class.perform_now(check_ins: check_ins_other_date) }

        it_behaves_like 'not broadcasting'
      end
    end

    context 'without imminent date' do
      it_behaves_like 'not broadcasting'
    end
  end
end
