# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::TicketCheckInJob do
  describe '#perform_now' do
    subject { described_class.perform_now(ticket_id: ticket_id, date: date.to_s, medium: medium) }

    let(:date) { ticket ? 15.minutes.after(ticket.date.admission_time) : Time.current }
    let(:medium) { 1 }
    let(:ticket) { nil }
    let(:ticket_id) { ticket.id }
    let(:current_time) { date.is_a?(Time) ? 15.seconds.after(date) : Time.current }

    around do |example|
      travel_to(current_time) { example.run }
    end

    shared_examples 'sending a COVID-19 check-in email' do
      it 'sends a COVID-19 check-in email' do
        expect { subject }
          .to have_enqueued_mail(Ticketing::Covid19CheckInMailer, :check_in)
          .with(a_hash_including(args: [ticket]))
          .at(date + 1.minute)
      end
    end

    shared_examples 'not sending a COVID-19 check-in email' do
      it 'sends a COVID-19 check-in email' do
        expect { subject }.not_to have_enqueued_mail(Ticketing::Covid19CheckInMailer)
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
        expect(check_in.date).to eq(date)
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
      let(:order) { create(:order, :with_tickets, tickets_count: 3, event: event) }
      let(:event) { create(:event, :complete, covid19: true, dates_count: 2) }
      let(:presence_tracing_email) { false }
      let(:ticket) { order.tickets[0] }
      let(:medium) { 2 }

      before do
        allow(Settings.covid19).to receive(:presence_tracing_email).and_return(presence_tracing_email)
        create(:cancellation, tickets: [order.tickets.last])
      end

      it 'creates a check-in for the ticket all of its valid order siblings' do
        expect { subject }.to change(Ticketing::CheckIn, :count).by(2)
        order.tickets[0..1].each do |ticket|
          check_in = ticket.check_ins.last
          expect(check_in.date).to eq(date)
          expect(check_in.medium).to eq('retail')
        end
      end

      include_examples 'not sending a COVID-19 check-in email'

      context 'with presence tracing email enabled' do
        let(:presence_tracing_email) { true }

        context 'when no other tickets from the order have been checked in yet' do
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

        context 'when it is too late for an email' do
          let(:current_time) { 2.hours.after(ticket.date.date) }

          include_examples 'not sending a COVID-19 check-in email'
        end
      end
    end

    describe 'avoiding multiple emails to the same person' do
      let(:order) { create(:order, :with_tickets, event: event) }
      let(:event) { create(:event, :complete, covid19: true) }

      it 'does not enqueue multiple emails to the same person' do
        expect do
          threads = 5.times.map do
            Thread.new do
              described_class.perform_now(ticket_id: order.tickets[0].id,
                                          date: date.to_s, medium: medium)
            end
          end
          threads.each(&:join)
        end.to have_enqueued_mail(Ticketing::Covid19CheckInMailer).once
      end
    end
  end
end
