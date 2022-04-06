# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::TicketUpdateService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, params:) }
  let(:orders) { create_list(:order, 3, :with_tickets, tickets_count: 3, event:) }
  let(:tickets) { Ticketing::Ticket.where(order: orders) }
  let(:event) { create(:event, :complete) }
  let(:ticket_type) { create(:ticket_type, price: 34, event:) }
  let(:params) do
    {
      orders[0].tickets[0].id => { resale: true },
      orders[0].tickets[1].id => { type_id: ticket_type.id, resale: true },
      orders[0].tickets[2].id => { type_id: ticket_type.id },
      orders[1].tickets[0].id => { type_id: ticket_type.id },
      orders[2].tickets[0].id => { picked_up: true }
    }
  end

  it 'makes the desired ticket updates' do
    expect { subject }.to(
      change { orders[0].tickets[0].reload.resale }.to(true)
      .and(change { orders[0].tickets[1].reload.type }.to(ticket_type))
      .and(change { orders[0].tickets[1].reload.resale }.to(true))
      .and(change { orders[0].tickets[2].reload.type }.to(ticket_type))
      .and(change { orders[1].tickets[0].reload.type }.to(ticket_type))
      .and(change { orders[2].tickets[0].reload.picked_up }.to(true))
    )
  end

  it 'does not touch other tickets or attributes' do
    expect { subject }.to(
      not_change { orders[1].tickets[1].reload.attributes }
      .and(not_change { orders[1].tickets[2].reload.attributes })
      .and(not_change { orders[2].tickets[1].reload.attributes })
      .and(not_change { orders[2].tickets[1].reload.attributes })
    )
  end

  it "updates the order's balance" do
    orders.each do |order|
      order.update(total: 36)
      order.tickets.update(price: 12)
      order.billing_account.save
    end

    expect { subject }.to(
      change { orders[0].billing_account.reload.balance }.by(-44)
      .and(change { orders[1].billing_account.reload.balance }.by(-22))
      .and(not_change { orders[2].billing_account.reload.balance })
    )
  end

  describe 'logging' do
    it 'creates multiple log events for multiple kinds of updates' do
      expect { subject }.to change(orders[0].log_events, :count).by(2)

      log_event = orders[0].log_events[0]
      expect(log_event.action).to eq('updated_ticket_types')
      expect(log_event.info).to eq(count: 2)

      log_event = orders[0].log_events[1]
      expect(log_event.action).to eq('enabled_resale_for_tickets')
      expect(log_event.info).to eq(count: 2)
    end

    it_behaves_like 'creates a log event', :updated_ticket_types do
      let(:loggable) { orders[1] }
      let(:info) { { count: 1 } }
    end

    it_behaves_like 'does not create a log event' do
      let(:loggable) { orders[2] }
    end
  end
end
