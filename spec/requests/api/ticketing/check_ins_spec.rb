# frozen_string_literal: true

require 'support/api_requests'
require 'support/authentication'

RSpec.describe 'Api::Ticketing::CheckInsController' do
  describe 'POST #create' do
    subject { post_json api_ticketing_check_ins_path, params: }

    let(:params) do
      {
        check_ins: [
          {
            ticket_id: orders[0].tickets[0].id,
            date: '2021-05-13 18:33:15',
            medium: 0
          },
          {
            ticket_id: orders[1].tickets[0].id,
            date: '2021-05-13 18:34:46',
            medium: 1
          },
          {
            ticket_id: orders[1].tickets[1].id,
            date: '2021-05-13 18:34:46',
            medium: 1
          },
          {
            ticket_id: 0,
            date: '2021-05-13 18:35:21',
            medium: 0
          }
        ]
      }
    end
    let(:orders) { create_list(:order, 2, :with_tickets, tickets_count: 2) }

    context 'when unauthorized' do
      it 'refuses the request' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not enqueue any jobs' do
        expect { subject }.not_to have_enqueued_job(Ticketing::TicketCheckInJob)
      end
    end

    context 'when authorized' do
      before { sign_in_api }

      it 'does not complain about invalid ticket ids' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'enqueues only as many jobs as there are check-ins' do
        expect { subject }.to have_enqueued_job(Ticketing::TicketCheckInJob).exactly(4).times
      end

      it 'enqueues check-in jobs for all ticket ids' do
        subject
        params[:check_ins].each do |check_in|
          expect(Ticketing::TicketCheckInJob).to have_been_enqueued.with(check_in)
        end
      end
    end
  end
end
