# frozen_string_literal: true

RSpec.describe Ticketing::TicketCancelService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, reason: reason) }
  let(:orders) { create_list(:web_order, 2, :with_tickets, tickets_count: 2) }
  let(:tickets) { orders.map(&:tickets).flatten }
  let(:valid_tickets) { tickets.first(3) }
  let(:invalid_ticket) do
    ticket = tickets.last
    create(:cancellation, tickets: [ticket])
    ticket
  end
  let(:reason) { 'foo' }

  it 'creates a cancellation' do
    expect { subject }.to change(Ticketing::Cancellation, :count).by(1)
  end

  it 'creates a cancellation only for previously valid tickets' do
    subject
    cancellation = Ticketing::Cancellation.last
    expect(cancellation.reason).to eq(reason)
    expect(cancellation.tickets).to include(*valid_tickets)
    expect(cancellation.tickets).not_to include(invalid_ticket)
  end

  it 'sends a cancellation confirmation email once per order' do
    expect { subject }
      .to have_enqueued_mail(Ticketing::OrderMailer, :cancellation)
      .with(a_hash_including(params: { reason: reason, order: orders[0] }))
      .and(
        have_enqueued_mail(Ticketing::OrderMailer, :cancellation)
          .with(a_hash_including(params: { reason: reason, order: orders[1] }))
      )
  end
end
