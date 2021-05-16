# frozen_string_literal: true

RSpec.describe Ticketing::TicketCheckInJob do
  describe '#perform_now' do
    subject do
      described_class.perform_now(ticket_id: ticket_id, date: date,
                                  medium: medium)
    end

    let(:date) { '2021-05-13 18:33:15' }
    let(:medium) { 1 }
    let(:ticket_id) { ticket.id }

    shared_examples 'sending a COVID-19 check-in email' do
      it 'sends a COVID-19 check-in email' do
        expect { subject }
          .to have_enqueued_mail(Ticketing::Covid19CheckInMailer, :check_in)
          .with(a_hash_including(args: [ticket]))
      end
    end

    shared_examples 'not sending a COVID-19 check-in email' do
      it 'sends a COVID-19 check-in email' do
        expect { subject }
          .not_to have_enqueued_mail(Ticketing::Covid19CheckInMailer)
      end
    end

    context 'with an invalid ticket id' do
      let(:ticket_id) { 'foo' }

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a ticket id from a non-covid19 order' do
      let(:order) { create(:order, :with_tickets, tickets_count: 2) }
      let(:ticket) { order.tickets[1] }

      it 'creates a check-in for the ticket' do
        expect { subject }.to change(Ticketing::CheckIn, :count).by(1)
        check_in = ticket.check_ins.last
        expect(check_in.date).to eq(Time.zone.parse(date))
        expect(check_in.medium).to eq('web')
      end

      include_examples 'not sending a COVID-19 check-in email'

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

    context 'with a ticket id from a covid19 order' do
      let(:order) do
        create(:order, :with_tickets, tickets_count: 3, event: event)
      end
      let(:event) do
        create(:event, :complete, covid19: true,
                                  covid19_presence_tracing: presence_tracing,
                                  dates_count: 2)
      end
      let(:presence_tracing) { false }
      let(:ticket) { order.tickets[0] }
      let(:medium) { 2 }

      before { create(:cancellation, tickets: [order.tickets.last]) }

      it 'creates a check-in for the ticket all of its valid order siblings' do
        expect { subject }.to change(Ticketing::CheckIn, :count).by(2)
        order.tickets[0..1].each do |ticket|
          check_in = ticket.check_ins.last
          expect(check_in.date).to eq(Time.zone.parse(date))
          expect(check_in.medium).to eq('retail')
        end
      end

      include_examples 'not sending a COVID-19 check-in email'

      context 'with presence tracing enabled' do
        let(:presence_tracing) { true }

        context 'when no other tickets from the order have been checked' \
                ' in yet' do
          include_examples 'sending a COVID-19 check-in email'
        end

        context 'when a ticket with the same date has been checked in' do
          before do
            order.tickets[1].update(date: ticket.date)
            order.tickets[1].check_ins.create(medium: 'web', date: Time.current)
          end

          include_examples 'not sending a COVID-19 check-in email'
        end

        context 'when a ticket with a different date has been checked in' do
          before do
            order.tickets[1].update(date: event.dates[1])
            order.tickets[1].check_ins.create(medium: 'web', date: Time.current)
          end

          include_examples 'sending a COVID-19 check-in email'
        end
      end
    end
  end
end
