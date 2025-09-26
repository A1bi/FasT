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

      it_behaves_like 'money transfer' do
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

      it_behaves_like 'money transfer' do
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

      it_behaves_like 'money transfer' do
        let(:amount) { -previous_balance }
      end
    end

    context 'with a positive balance' do
      it_behaves_like 'settles balance'
    end

    context 'with a negative balance' do
      let(:previous_balance) { -44 }

      it_behaves_like 'settles balance'
    end
  end

  describe '#settle_balance_with_bank_transaction' do
    subject { service.settle_balance_with_bank_transaction }

    let(:order) { create(:web_order, :complete, :charge_payment) }
    let(:previous_balance) { -25 }

    before { order.open_bank_transaction.update(amount: 10) }

    it 'settles the order\'s balance' do
      expect { subject }.to change(order, :balance).to(0)
    end

    context 'with a negative order balance' do
      let(:previous_balance) { -25 }

      it 'adds the order balance to the bank transaction' do
        expect { subject }.to change { order.open_bank_transaction.reload.amount }.to eq(35)
      end

      it_behaves_like 'sets transaction note', 'bank_charge_payment'
    end

    context 'with a positive order balance' do
      let(:previous_balance) { 25 }

      it 'subtracts the order balance from the bank transaction' do
        expect { subject }.to change { order.open_bank_transaction.reload.amount }.to eq(-15)
      end

      it_behaves_like 'sets transaction note', 'transfer_refund'
    end

    context 'without an open bank transaction' do
      before { create(:bank_submission, transactions: [order.open_bank_transaction]) }

      it 'does not change the order\'s balance' do
        expect { subject }.not_to change(order, :balance)
      end
    end

    context 'with a specific bank transaction' do
      subject { service.settle_balance_with_bank_transaction(bank_transaction) }

      let(:bank_transaction) { create(:bank_transaction) }

      it 'does not touch the other bank transaction' do
        expect { subject }.not_to(change { order.bank_transactions.first.amount })
      end

      it 'adds the total to the bank transaction' do
        expect { subject }.to change { bank_transaction.reload.amount }.to eq(25)
      end
    end
  end

  describe '#settle_balance_with_stripe' do
    subject { service.settle_balance_with_stripe(payment_method_id:) }

    let(:stripe_payment) { build(:stripe_payment, amount: 20, method: stripe_method) }
    let(:stripe_method) { :apple_pay }
    let(:payment_method_id) { 'foo' }

    context 'when order balance is outstanding' do
      let(:order) { create(:web_order, :complete, :with_balance, :stripe_payment) }
      let(:stripe_service) { instance_double(Ticketing::StripePaymentCreateService, execute: stripe_payment) }
      let(:previous_balance) { -40 }

      before { allow(Ticketing::StripePaymentCreateService).to receive(:new).and_return(stripe_service) }

      it 'calls stripe payment service' do
        expect(Ticketing::StripePaymentCreateService).to receive(:new).with(order, payment_method_id)
        subject
      end

      it 'adjusts order\'s balance' do
        expect { subject }.to change(order, :balance).from(previous_balance).to(-20)
      end

      context 'with Apple Pay' do
        it_behaves_like 'sets transaction note', 'apple_pay_payment'
      end

      context 'with Google Pay' do
        let(:stripe_method) { :google_pay }

        it_behaves_like 'sets transaction note', 'google_pay_payment'
      end
    end

    context 'when order has credit' do
      let(:order) { create(:web_order, :complete, :stripe_payment) }
      let(:stripe_service) { instance_double(Ticketing::StripeRefundCreateService, execute: stripe_refund) }
      let(:stripe_refund) { build(:stripe_refund, amount: previous_balance) }

      before do
        allow(Ticketing::StripeRefundCreateService).to receive(:new).and_return(stripe_service)
        allow(order).to receive(:stripe_payment).and_return(stripe_payment)
      end

      it 'calls stripe payment service' do
        expect(Ticketing::StripeRefundCreateService).to receive(:new).with(order)
        subject
      end

      it 'adjusts order\'s balance' do
        expect { subject }.to change(order, :balance).from(previous_balance).to(0)
      end

      context 'with Apple Pay' do
        it_behaves_like 'sets transaction note', 'apple_pay_refund'
      end

      context 'with Google Pay' do
        let(:stripe_method) { :google_pay }

        it_behaves_like 'sets transaction note', 'google_pay_refund'
      end
    end

    context 'when order uses different payment method' do
      let(:order) { create(:web_order, :complete, :with_balance, :transfer_payment) }

      it 'does not call stripe payment service' do
        expect(Ticketing::StripePaymentCreateService).not_to receive(:new)
        subject
      end

      it 'does not adjust order\'s balance' do
        expect { subject }.not_to change(order, :balance)
      end
    end
  end

  describe '#settle_balance_with_retail_account' do
    subject { service.settle_balance_with_retail_account }

    let(:order) { create(:retail_order, :complete) }

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

      it_behaves_like 'sets transaction note', 'cash_in_store'
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

      it_behaves_like 'does not change the balance'
    end
  end

  describe '#refund_in_retail_store' do
    subject { service.refund_in_retail_store }

    context 'with a web order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      it_behaves_like 'does not change the balance'
    end

    context 'with a retail order' do
      let(:order) { create(:retail_order, :with_purchased_coupons, :unpaid) }

      context 'with a negative balance' do
        let(:previous_balance) { -55 }

        it_behaves_like 'does not change the balance'
      end

      context 'with a positive balance' do
        it 'settles the balance' do
          expect { subject }.to change(order.billing_account, :balance).from(previous_balance).to(0)
        end

        it_behaves_like 'sets transaction note', 'cash_refund_in_store'
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

      it_behaves_like 'sets transaction note', 'correction'
    end

    context 'with a positive amount' do
      let(:amount) { 22 }

      it_behaves_like 'adjusts balance'
    end

    context 'with a negative amount' do
      let(:amount) { -44 }

      it_behaves_like 'adjusts balance'
    end
  end

  describe '#deposit_coupon_credit' do
    subject { service.deposit_coupon_credit(coupon) }

    shared_examples 'changes neither order nor coupon balance' do
      it 'does not change the coupon balance' do
        expect { subject }.not_to(change { coupon.reload.value })
      end

      it_behaves_like 'does not change the balance'
    end

    context 'with a coupon without credit' do
      let(:coupon) { create(:coupon) }

      it_behaves_like 'changes neither order nor coupon balance'
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

        it_behaves_like 'sets transaction note', 'redeemed_coupon'
      end

      context 'when order has credit' do
        it_behaves_like 'changes neither order nor coupon balance'
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
