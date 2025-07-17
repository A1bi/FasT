# frozen_string_literal: true

RSpec.describe BackstageTvChannel do
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
        .and(have_stream_from(:ticketing_seats_checked_in))
    end

    it 'enqueues initial update broadcasting' do
      expect { subject }.to have_enqueued_job(Ticketing::BroadcastTicketsSoldJob)
    end
  end
end
