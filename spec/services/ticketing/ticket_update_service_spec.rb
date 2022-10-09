# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::TicketUpdateService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, params:) }
  let(:order) { create(:order, :with_tickets, tickets_count: 5, event:) }
  let(:tickets) { order.tickets }
  let(:event) { create(:event, :complete) }
  let(:ticket_type) { create(:ticket_type, price: 34, event:) }
  let(:params) do
    {
      tickets[0].id => { resale: true },
      tickets[1].id => { type_id: ticket_type.id, resale: true },
      tickets[3].id => { type_id: ticket_type.id },
      tickets[4].id => { picked_up: true }
    }
  end

  it 'makes the desired ticket updates' do
    expect { subject }.to(
      change { tickets[0].reload.resale }.to(true)
      .and(change { tickets[1].reload.resale }.to(true))
      .and(change { tickets[1].reload.type }.to(ticket_type))
      .and(change { tickets[3].reload.type }.to(ticket_type))
      .and(change { tickets[4].reload.picked_up }.to(true))
    )
  end

  it 'does not touch other tickets or attributes' do
    expect { subject }.not_to(change { tickets[2].reload.attributes })
  end

  it "updates the order's balance" do
    order.update(total: 60)
    tickets.update(price: 12)

    expect { subject }.to change { order.billing_account.reload.balance }.by(-44)
  end

  describe 'logging' do
    it 'creates multiple log events for multiple kinds of updates' do
      expect { subject }.to change(order.log_events, :count).by(2)

      log_event = order.log_events[0]
      expect(log_event.action).to eq('updated_ticket_types')
      expect(log_event.info).to eq(count: 2)

      log_event = order.log_events[1]
      expect(log_event.action).to eq('enabled_resale_for_tickets')
      expect(log_event.info).to eq(count: 2)
    end
  end

  context 'when not all tickets are from the same order' do
    let(:orders) { create_list(:order, 2, :with_tickets, tickets_count: 3, event:) }
    let(:tickets) { Ticketing::Ticket.where(order: orders) }

    it 'does raise an error' do
      expect { subject }.to raise_error(described_class::TicketsFromDifferentOrdersError)
    end
  end
end
