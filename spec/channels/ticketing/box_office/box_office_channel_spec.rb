# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::BoxOfficeChannel do
  before { stub_connection }

  describe '#subscribed' do
    subject do
      subscribe
      subscription
    end

    it 'streams from various broadcastings' do
      expect(subject)
        .to have_stream_from(:ticketing_check_ins)
        .and(have_stream_from(:ticketing_tickets_sold))
        .and(have_stream_from(:ticketing_seats_booked))
    end

    it 'enqueues initial update broadcastings' do
      expect { subject }.to(
        have_enqueued_job(Ticketing::BroadcastTicketsSoldJob)
        .and(have_enqueued_job(Ticketing::BroadcastCheckInsJob))
      )
    end
  end
end
