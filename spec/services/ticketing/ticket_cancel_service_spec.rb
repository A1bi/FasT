# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::TicketCancelService do
  subject { service.execute }

  let(:service) { described_class.new(tickets, reason:) }
  let(:order) { create(:web_order, :with_tickets, tickets_count: 4) }
  let(:tickets) { order.tickets }
  let(:reason) { 'foo' }
  let(:refund_service) { instance_double(Ticketing::OrderRefundService, execute: :foo_transaction) }

  before do
    allow(Ticketing::OrderRefundService).to receive(:new).and_return(refund_service)
  end

  shared_examples 'cancellation confirmation sending' do |refund_transaction|
    let(:cancellation) { create(:cancellation) }

    before { allow(Ticketing::Cancellation).to receive(:create).and_return(cancellation) }

    it 'sends a cancellation confirmation email once per order with a bank transaction' do
      expect { subject }
        .to have_enqueued_mail(Ticketing::OrderMailer, :cancellation)
        .with(a_hash_including(params: { reason:, order:, cancellation:, refund_transaction: }))
    end
  end

  context 'when some tickets are already invalid' do
    let(:valid_tickets) { tickets[0..1] }
    let!(:invalid_ticket) do
      create(:cancellation, tickets: [tickets[3]])
      tickets[3]
    end
    let!(:resale_ticket) do
      tickets[2].update(resale: true)
      tickets[2]
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
      order.tickets.update(price: 10)
      order.update(total: 30)

      expect { subject }.to change { order.billing_account.reload.balance }.by(30)
    end

    context 'without refund requested' do
      it 'does not refund the order' do
        expect(Ticketing::OrderRefundService).not_to receive(:new)
        subject
      end

      it_behaves_like 'cancellation confirmation sending', nil
    end

    context 'with refund requested' do
      subject { service.execute(refund: :foo) }

      it 'refunds the order' do
        expect(Ticketing::OrderRefundService).to receive(:new).with(order)
        expect(refund_service).to receive(:execute).with(:foo)
        subject
      end

      it_behaves_like 'cancellation confirmation sending', :foo_transaction
    end

    it_behaves_like 'creates a log event', :cancelled_tickets do
      let(:loggable) { order }
      let(:info) { { count: 3, reason: } }
    end

    context 'with a cancellation by customer' do
      let(:reason) { :self_service }

      it_behaves_like 'creates a log event', :cancelled_tickets_by_customer do
        let(:loggable) { order }
        let(:info) { { count: 3 } }
      end
    end

    it 'queues a tickets sold broadcast' do
      expect { subject }.to have_enqueued_job(Ticketing::BroadcastTicketsSoldJob).with(tickets:)
    end
  end

  context 'when all tickets are already invalid' do
    let(:tickets) { Ticketing::Ticket.none }

    it 'does not create an empty cancellation' do
      expect { subject }.not_to change(Ticketing::Cancellation, :count)
    end
  end

  context 'when not all tickets are from the same order' do
    let(:orders) { create_list(:web_order, 2, :with_tickets, tickets_count: 2) }
    let(:tickets) { orders.map(&:tickets).flatten }

    it 'does raise an error' do
      expect { subject }.to raise_error(described_class::TicketsFromDifferentOrdersError)
    end
  end
end
