# frozen_string_literal: true

RSpec.describe Ticketing::OrderBillingService do
  let(:service) { described_class.new(order) }
  let(:order) { create(:order, :with_tickets) }
  let(:previous_balance) { 33 }
  let(:note) { 'barfoo' }

  before { order.billing_account.update(balance: previous_balance) }

  shared_examples 'transfer creation' do
    it 'creates a transfer' do
      expect { subject }
        .to change(order.billing_account.transfers, :count).by(1)
      transfer = order.billing_account.transfers.last
      expect(transfer.amount).to eq(amount)
      expect(transfer.note_key).to eq(note)
    end
  end

  describe '#update_balance' do
    let(:tickets) { order.tickets }
    let(:ticket_price) { 11 }

    before do
      order.update(total: ticket_price * tickets.count)
      tickets.update(price: ticket_price)
    end

    context 'when an item is cancelled' do
      subject do
        service.update_balance(note) do
          Ticketing::Cancellation.create(tickets: [tickets.last], reason: 'foo')
        end
      end

      it 'deducts the cancelled ticket price from the balance' do
        expect { subject }
          .to change(order.billing_account, :balance).by(ticket_price)
      end

      include_examples 'transfer creation' do
        let(:amount) { ticket_price }
      end
    end

    context 'when the price for an item changes' do
      subject do
        service.update_balance(note) do
          tickets.last.update(price: ticket_price_after)
        end
      end

      let(:ticket_price_after) { 18 }
      let(:diff) { ticket_price - ticket_price_after }

      it 'deducts the difference of new and old price from the balance' do
        expect { subject }
          .to change(order.billing_account, :balance).by(diff)
      end

      include_examples 'transfer creation' do
        let(:amount) { diff }
      end
    end
  end

  describe '#settle_balance' do
    subject { service.settle_balance(note) }

    shared_examples 'settles balance' do
      it 'changes the balance to 0' do
        expect { subject }
          .to change(order.billing_account, :balance)
          .from(previous_balance).to(0)
      end

      include_examples 'transfer creation' do
        let(:amount) { -previous_balance }
      end
    end

    context 'with a positive balance' do
      include_examples 'settles balance'
    end

    context 'with a negative balance' do
      let(:previous_balance) { -44 }

      include_examples 'settles balance'
    end
  end
end
