# frozen_string_literal: true

RSpec.describe Ticketing::TicketCancelService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, reason) }
  let(:orders) { create_list(:web_order, 2, :with_tickets, tickets_count: 2) }
  let(:tickets) { orders.map(&:tickets).flatten }
  let(:reason) { 'foo' }

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
