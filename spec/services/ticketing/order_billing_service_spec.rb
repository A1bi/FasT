# frozen_string_literal: true

RSpec.describe Ticketing::OrderBillingService do
  let(:service) { described_class.new(order) }
  let(:order) { create(:order, :with_tickets) }
  let(:previous_balance) { 33 }
  let(:note) { 'barfoo' }

  before { order.billing_account.update(balance: previous_balance) }

  shared_examples 'money transfer' do
    it 'creates a transaction' do
      expect { subject }.to change(order.billing_account.transactions, :count).by(1)
      transaction = order.billing_account.transactions.last
      expect(transaction.amount).to eq(amount)
      expect(transaction.note_key).to eq(note)
    end

    it "updates the order's paid status" do
      expect(order).to receive(:update_paid)
      subject
    end
  end

  shared_examples 'does not change the balance' do
    it 'does not change the balance' do
      expect { subject }.not_to change(order.billing_account, :balance)
    end
  end

  shared_examples 'sets transaction note' do |note_key|
    it 'sets the right transaction note' do
      subject
      transaction = order.billing_account.transactions.last
      expect(transaction.note_key).to eq(note_key)
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
        expect { subject }.to change(order.billing_account, :balance).by(ticket_price)
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
        expect { subject }.to change(order.billing_account, :balance).by(diff)
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
        expect { subject }.to change(order.billing_account, :balance).from(previous_balance).to(0)
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
      order.store.billing_account.update(balance: 20) if order.try(:store)
    end

    context 'with a negative balance' do
      let(:previous_balance) { -55 }

      it 'withdraws the negative balance from the store billing account' do
        expect { subject }.to(
          change { order.billing_account.reload.balance }.from(-55).to(0)
          .and(change { order.store.billing_account.reload.balance }
                .from(20).to(-35))
        )
      end

      include_examples 'sets transaction note', 'cash_in_store'
    end

    context 'with a positive balance' do
      it 'deposits the positive balance into the store billing account' do
        expect { subject }.to(
          change { order.billing_account.reload.balance }.from(previous_balance).to(0)
          .and(change { order.store.billing_account.reload.balance }.from(20).to(20 + previous_balance))
        )
      end
    end

    context 'with a web order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      include_examples 'does not change the balance'
    end
  end

  describe '#refund_in_retail_store' do
    subject { service.refund_in_retail_store }

    context 'with a web order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      include_examples 'does not change the balance'
    end

    context 'with a retail order' do
      let(:order) { create(:retail_order, :with_purchased_coupons, :unpaid) }

      context 'with a negative balance' do
        let(:previous_balance) { -55 }

        include_examples 'does not change the balance'
      end

      context 'with a positive balance' do
        it 'settles the balance' do
          expect { subject }.to change(order.billing_account, :balance).from(previous_balance).to(0)
        end

        include_examples 'sets transaction note', 'cash_refund_in_store'
      end
    end
  end

  describe '#adjust_balance' do
    subject { service.adjust_balance(amount) }

    shared_examples 'adjusts balance' do
      it 'changes the balance to 0' do
        expect { subject }
          .to change(order.billing_account, :balance)
          .from(previous_balance).to(previous_balance + amount)
      end

      include_examples 'sets transaction note', 'correction'
    end

    context 'with a positive amount' do
      let(:amount) { 22 }

      include_examples 'adjusts balance'
    end

    context 'with a negative amount' do
      let(:amount) { -44 }

      include_examples 'adjusts balance'
    end
  end

  describe '#deposit_coupon_credit' do
    subject { service.deposit_coupon_credit(coupon) }

    shared_examples 'changes neither order nor coupon balance' do
      it 'does not change the coupon balance' do
        expect { subject }.not_to(change { coupon.reload.value })
      end

      include_examples 'does not change the balance'
    end

    context 'with a coupon without credit' do
      let(:coupon) { create(:coupon) }

      include_examples 'changes neither order nor coupon balance'
    end

    context 'with a coupon with credit' do
      let(:coupon) { create(:coupon, :credit, value: 25) }

      shared_examples 'transfers from coupon to order' do
        it 'withdraws the negative balance from the coupon billing account' do
          expect { subject }.to(
            change(order.billing_account, :balance).from(previous_balance)
                                                   .to(new_order_balance)
            .and(change(coupon, :value).from(coupon.value)
                                       .to(new_coupon_balance))
          )
        end

        include_examples 'sets transaction note', 'redeemed_coupon'
      end

      context 'when order has credit' do
        include_examples 'changes neither order nor coupon balance'
      end

      context 'when order has balance greather than coupon credit' do
        let(:previous_balance) { -42 }

        it_behaves_like 'transfers from coupon to order' do
          let(:new_order_balance) { -17 }
          let(:new_coupon_balance) { 0 }
        end
      end

      context 'when order has balance less than coupon credit' do
        let(:previous_balance) { -24 }

        it_behaves_like 'transfers from coupon to order' do
          let(:new_order_balance) { 0 }
          let(:new_coupon_balance) { 1 }
        end
      end

      context 'when order balance equals coupon credit' do
        let(:previous_balance) { -25 }

        it_behaves_like 'transfers from coupon to order' do
          let(:new_order_balance) { 0 }
          let(:new_coupon_balance) { 0 }
        end
      end
    end
  end
end
