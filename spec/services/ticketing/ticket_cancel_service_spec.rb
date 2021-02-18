# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::TicketCancelService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, reason: reason) }
  let(:orders) { create_list(:web_order, 2, :with_tickets, tickets_count: 3) }
  let(:tickets) { orders.map(&:tickets).flatten.first(5) }
  let(:valid_tickets) { tickets.first(4) }
  let!(:invalid_ticket) do
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
    expect(cancellation.tickets).to contain_exactly(*valid_tickets)
    expect(cancellation.tickets).not_to include(invalid_ticket)
  end

  it "updates the order's balance" do
    orders.each do |order|
      order.tickets.update(price: 10)
      order.billing_account.save
    end
    orders[0].update(total: 30)
    orders[1].update(total: 20)

    expect { subject }.to(
      change { orders[0].billing_account.reload.balance }.by(30)
      .and(change { orders[1].billing_account.reload.balance }.by(10))
    )
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

  include_examples 'creates a log event', :cancelled_tickets do
    let(:loggable) { orders.first }
    let(:info) { { count: 3, reason: reason } }
  end

  include_examples 'creates a log event', :cancelled_tickets do
    let(:loggable) { orders.last }
    let(:info) { { count: 1, reason: reason } }
  end
end
