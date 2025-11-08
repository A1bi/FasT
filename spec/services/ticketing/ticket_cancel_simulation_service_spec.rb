# frozen_string_literal: true

RSpec.describe Ticketing::TicketCancelSimulationService do
  let(:service) { described_class.new(tickets) }
  let(:order) { create(:web_order, :with_tickets, tickets_count: 4) }
  let(:tickets) { [order.tickets[0], order.tickets[3]] }

  before do
    order.tickets[0].update(price: 23)
    order.tickets[1].update(cancellation: build(:cancellation))
    order.tickets[3].update(price: 45)
    order.update_total
    order.save
  end

  describe '#refund_amount' do
    subject { service.refund_amount }

    it { is_expected.to eq(68) }

    it 'does not touch the order' do
      expect { subject }.not_to(change(order, :reload))
    end

    it 'does not change the in-memory total' do
      expect { subject }.not_to(change(order, :total))
    end

    it 'does not create a cancellation' do
      expect { subject }.not_to(change(Ticketing::Cancellation, :count))
    end
  end
end
