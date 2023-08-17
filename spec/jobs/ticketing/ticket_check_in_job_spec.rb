# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::TicketCheckInJob do
  describe '#perform_now' do
    subject { described_class.perform_now(ticket_id:, date: date.to_s, medium:) }

    let(:date) { ticket ? 15.minutes.after(ticket.date.admission_time) : Time.current }
    let(:medium) { 1 }
    let(:ticket) { nil }
    let(:ticket_id) { ticket.id }
    let(:current_time) { date.is_a?(Time) ? 15.seconds.after(date) : Time.current }

    before { travel_to(current_time) }

    context 'with an invalid ticket id' do
      let(:ticket_id) { 'foo' }

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with valid ticket data' do
      let(:order) { create(:order, :with_tickets, tickets_count: 2) }
      let(:ticket) { order.tickets[1] }

      it 'creates a check-in for the ticket' do
        expect { subject }.to change(Ticketing::CheckIn, :count).by(1)
        check_in = ticket.check_ins.last
        expect(check_in.date).to eq(date)
        expect(check_in.medium).to eq('web')
      end

      context 'with an invalid date' do
        let(:date) { 'foobar' }

        it 'raises an error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'with an invalid medium' do
        let(:medium) { 'foo' }

        it 'raises an error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
