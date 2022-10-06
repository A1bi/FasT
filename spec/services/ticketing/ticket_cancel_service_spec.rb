# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::TicketCancelService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, reason:) }
  let(:orders) { create_list(:web_order, 2, :with_tickets, tickets_count: 3) }
  let(:tickets) { orders.map(&:tickets).flatten.first(5) }
  let(:reason) { 'foo' }
  let(:refund_service) { instance_double(Ticketing::OrderRefundService, execute: :foo_transaction) }

  before do
    allow(Ticketing::OrderRefundService).to receive(:new).and_return(refund_service)
  end

  shared_examples 'cancellation confirmation sending' do |bank_transaction|
    it 'sends a cancellation confirmation email once per order with a bank transaction' do
      expect { subject }
        .to have_enqueued_mail(Ticketing::OrderMailer, :cancellation)
        .with(a_hash_including(params: { reason:, order: orders[0], bank_transaction: }))
        .and(
          have_enqueued_mail(Ticketing::OrderMailer, :cancellation)
            .with(a_hash_including(params: { reason:, order: orders[1], bank_transaction: }))
        )
    end
  end

  context 'when some tickets are already invalid' do
    let(:valid_tickets) { tickets.first(3) }
    let!(:invalid_ticket) do
      ticket = tickets[-1]
      create(:cancellation, tickets: [ticket])
      ticket
    end
    let!(:resale_ticket) do
      ticket = tickets[-2]
      ticket.update(resale: true)
      ticket
    end

    it 'creates a cancellation' do
      expect { subject }.to change(Ticketing::Cancellation, :count).by(1)
    end

    it 'creates a cancellation only for previously valid tickets' do
      subject
      cancellation = Ticketing::Cancellation.last
      expect(cancellation.reason).to eq(reason)
      expect(cancellation.tickets).to contain_exactly(*valid_tickets, resale_ticket)
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

    context 'without refund requested' do
      it 'does not refund the orders' do
        expect(Ticketing::OrderRefundService).not_to receive(:new)
        subject
      end

      include_examples 'cancellation confirmation sending', nil
    end

    context 'with refund requested' do
      subject { service.execute(refund: :foo) }

      it 'refunds all of the orders' do
        expect(Ticketing::OrderRefundService).to receive(:new).with(orders[0])
        expect(Ticketing::OrderRefundService).to receive(:new).with(orders[1])
        expect(refund_service).to receive(:execute).with(:foo).twice
        subject
      end

      include_examples 'cancellation confirmation sending', :foo_transaction
    end

    include_examples 'creates a log event', :cancelled_tickets do
      let(:loggable) { orders.first }
      let(:info) { { count: 3, reason: } }
    end

    include_examples 'creates a log event', :cancelled_tickets do
      let(:loggable) { orders.last }
      let(:info) { { count: 1, reason: } }
    end
  end

  context 'when all tickets are already invalid' do
    let(:tickets) { Ticketing::Ticket.none }

    it 'does not create an empty cancellation' do
      expect { subject }.not_to change(Ticketing::Cancellation, :count)
    end
  end
end
