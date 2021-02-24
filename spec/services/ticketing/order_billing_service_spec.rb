# frozen_string_literal: true

RSpec.describe Ticketing::OrderBillingService do
  let(:service) { described_class.new(order) }
  let(:order) { create(:order, :with_tickets) }
  let(:previous_balance) { 33 }
  let(:note) { 'barfoo' }

  before { order.billing_account.update(balance: previous_balance) }

  shared_examples 'money transfer' do
    it 'creates a transfer' do
      expect { subject }
        .to change(order.billing_account.transfers, :count).by(1)
      transfer = order.billing_account.transfers.last
      expect(transfer.amount).to eq(amount)
      expect(transfer.note_key).to eq(note)
    end

    it "updates the order's paid status" do
      expect(order).to receive(:update_paid)
      subject
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
          create(:cancellation, tickets: [tickets.last])
        end
      end

      it 'deducts the cancelled ticket price from the balance' do
        expect { subject }
          .to change(order.billing_account, :balance).by(ticket_price)
      end

      include_examples 'money transfer' do
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

      include_examples 'money transfer' do
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

      include_examples 'money transfer' do
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

  describe '#settle_balance_with_retail_account' do
    subject { service.settle_balance_with_retail_account }

    let(:order) { create(:retail_order, :with_purchased_coupons) }

    before do
      order.billing_account.update(balance: balance)
      order.store.billing_account.update(balance: 20)
    end

    context 'with a negative balance' do
      let(:balance) { -55 }

      it 'withdraws the negative balance from the store billing account' do
        expect { subject }.to(
          change { order.billing_account.reload.balance }.from(-55).to(0)
          .and(change { order.store.billing_account.reload.balance }
                .from(20).to(-35))
        )
      end

      it 'sets a default transfer note if none provided' do
        subject
        transfer = order.billing_account.transfers.last
        expect(transfer.note_key).to eq('cash_in_store')
      end
    end

    context 'with a positive balance' do
      let(:balance) { 77 }

      it 'deposits the positive balance into the store billing account' do
        expect { subject }.to(
          change { order.billing_account.reload.balance }.from(77).to(0)
          .and(change { order.store.billing_account.reload.balance }
                .from(20).to(97))
        )
      end
    end
  end
end
