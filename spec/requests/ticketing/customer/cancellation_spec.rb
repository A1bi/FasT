# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Ticketing::Customer::CancellationController' do
  describe 'POST #refund_amount' do
    subject { post customer_cancellation_refund_amount_path(authenticated_signed_info, params) }

    let(:params) { { ticket_ids: tickets.map(&:id) } }
    let(:order) { create(:web_order, :with_tickets, tickets_count: 4) }
    let(:tickets) { order.tickets[1..3] }
    let(:amount_service) { instance_double(Ticketing::TicketCancelSimulationService, refund_amount: 123) }

    before do
      order.tickets[1].update(cancellation: build(:cancellation))
      past_date = create(:event_date, event: order.event, date: 1.day.ago)
      order.tickets[2].update(date: past_date)
      allow(Ticketing::TicketCancelSimulationService).to receive(:new).and_return(amount_service)
    end

    it 'passes only cancellable tickets to the service' do
      expect(Ticketing::TicketCancelSimulationService).to receive(:new).with([order.tickets[3]])
      subject
    end

    it 'returns the amount from the service' do
      subject
      expect(response.parsed_body).to eq('amount' => 123)
    end
  end
end
