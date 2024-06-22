# frozen_string_literal: true

RSpec.describe Ticketing::OrderRefundService do
  subject { service.execute(params) }

  let(:service) { described_class.new(order) }
  let!(:order) { create(:web_order, :complete, payment, :with_credit) }
  let(:payment) { :charge_payment }

  shared_examples 'without credit' do
    context 'without credit' do
      let(:order) { create(:web_order, :complete, payment) }

      it 'does not touch balances' do
        expect { subject }.not_to change(order, :balance)
      end

      it 'does not create a bank transaction' do
        expect { subject }.not_to change(Ticketing::BankTransaction, :count)
      end

      it 'does not call billing service' do
        expect(Ticketing::OrderBillingService).not_to receive(:new)
        subject
      end
    end
  end

  shared_examples 'creates a new bank transaction with the correct amount' do
    it 'creates a new bank transaction with the correct amount' do
      expect { subject }.to change(Ticketing::BankTransaction, :count).by(1)
      transaction = Ticketing::BankTransaction.last
      expect(transaction.amount).to eq(-123)
    end
  end

  context 'when using the most recent existing bank transaction' do
    let(:params) { { use_most_recent: true } }

    context 'when an open bank transaction exists' do
      it 'settles the credit with the open bank transaction' do
        expect { subject }.to change(order, :balance).to(0).and(
          change(order.open_bank_transaction, :amount).by(-123)
        )
      end

      include_examples 'without credit'
    end

    context 'when only submitted bank transactions exist' do
      let(:payment) { :submitted_charge_payment }

      it "settles the order's credit" do
        expect { subject }.to change(order, :balance).to(0)
      end

      it 'creates a new bank transaction with the correct details' do
        subject
        transaction = Ticketing::BankTransaction.last
        previous = order.bank_transactions.first
        expect(transaction).not_to eq(previous)
        expect(transaction.attributes.slice('name', 'iban'))
          .to eq(previous.attributes.slice('name', 'iban'))
      end

      include_examples 'creates a new bank transaction with the correct amount'
      include_examples 'without credit'
    end

    context 'when no bank transactions exist' do
      let(:order) { create(:web_order, :complete, :with_credit) }

      it { is_expected.to be_falsy }
    end
  end

  context 'with a new bank transaction' do
    let(:params) { { name: 'Johnny Doe', iban: 'DE02200505501015871393' } }

    it "settles the order's credit" do
      expect { subject }.to change(order, :balance).to(0)
    end

    it 'creates a new bank transaction with the correct details' do
      subject
      transaction = Ticketing::BankTransaction.last
      expect(transaction.attributes.slice('name', 'iban')).to eq(params.stringify_keys)
    end

    context 'with invalid bank details' do
      let(:params) { super().merge(iban: 'DEFOO') }

      it { is_expected.to be_falsy }
    end

    include_examples 'creates a new bank transaction with the correct amount'
    include_examples 'without credit'
  end

  context 'with Stripe payment' do
    let(:payment) { :stripe_payment }
    let(:params) { {} }
    let(:billing_service) { instance_double(Ticketing::OrderBillingService, :settle_balance_with_stripe) }

    before { allow(Ticketing::OrderBillingService).to receive(:new).with(order).and_return(billing_service) }

    it 'refunds with Stripe' do
      expect(billing_service).to receive(:settle_balance_with_stripe)
      subject
    end

    include_examples 'without credit'
  end
end
