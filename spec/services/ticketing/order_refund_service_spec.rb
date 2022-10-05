# frozen_string_literal: true

RSpec.describe Ticketing::OrderRefundService do
  subject { service.execute(params) }

  let(:service) { described_class.new(order) }
  let!(:order) { create(:web_order, :complete, :charge_payment, :with_credit) }
  let(:params) { { bank_transaction: transaction_params } }

  shared_examples 'without credit' do
    context 'without credit' do
      let(:order) { create(:web_order, :complete, :charge_payment) }

      it 'does not touch balances' do
        expect { subject }.not_to change(order, :balance)
      end

      it 'does not create a bank transaction' do
        expect { subject }.not_to change(Ticketing::BankTransaction, :count)
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

  context 'with an open bank transaction' do
    let(:transaction_params) { { open: true } }

    it 'settles the credit with the open bank transaction' do
      expect { subject }.to change(order, :balance).to(0).and(
        change(order.open_bank_transaction, :amount).by(-123)
      )
    end

    context 'without open bank transaction' do
      let(:order) { create(:web_order, :complete, :with_credit) }

      it { is_expected.to be_falsy }
    end

    context 'without credit' do
      let(:order) { create(:web_order, :complete, :charge_payment) }

      it 'does not touch balances' do
        expect { subject }.to not_change(order, :balance).and(
          not_change(order.open_bank_transaction, :amount)
        )
      end
    end
  end

  context 'with the most recent bank transaction' do
    let(:transaction_params) { { previous: true } }

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

    context 'without a most recent bank transaction' do
      let(:order) { create(:web_order, :complete, :with_credit) }

      it { is_expected.to be_falsy }
    end

    include_examples 'creates a new bank transaction with the correct amount'
    include_examples 'without credit'
  end

  context 'with a new bank transaction' do
    let(:transaction_params) { { name: 'Johnny Doe', iban: 'DE02200505501015871393' } }

    it "settles the order's credit" do
      expect { subject }.to change(order, :balance).to(0)
    end

    it 'creates a new bank transaction with the correct details' do
      subject
      transaction = Ticketing::BankTransaction.last
      expect(transaction.attributes.slice('name', 'iban')).to eq(transaction_params.stringify_keys)
    end

    context 'with invalid bank details' do
      let(:transaction_params) { super().merge(iban: 'DEFOO') }

      it { is_expected.to be_falsy }
    end

    include_examples 'creates a new bank transaction with the correct amount'
    include_examples 'without credit'
  end
end
