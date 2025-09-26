# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::ReceivedTransferPaymentProcessService do
  subject { service.execute }

  let(:service) { described_class.new }
  let(:ebics) { instance_double(Ticketing::EbicsService, transactions:) }
  let(:transactions) { [transaction_debit, transaction] }
  let(:transaction_debit) { instance_double(Cmxl::Fields::Transaction, credit?: false) }
  let(:transaction) do
    instance_double(Cmxl::Fields::Transaction,
                    credit?: true, amount:, sha:, name: transaction_details['name'],
                    sepa: { 'SVWZ' => reference, 'MREF' => mref }.compact,
                    to_h: transaction_details)
  end
  let(:transaction_details) { { 'name' => 'Johnny Doe', 'iban' => 'DE75512108001245126199', 'amount' => amount.to_f } }
  let(:amount) { -order.balance }
  let(:reference) { "Bestellung #{order.number}" }
  let(:sha) { 'abc123' }
  let(:mref) { nil }
  let(:orders) { create_list(:order, 3, :complete, :unpaid, :with_balance) }
  let(:order) { orders[0] }
  let(:date) { Date.parse('2024-05-11') }

  before do
    allow(Ticketing::EbicsService).to receive(:new).and_return(ebics)
    travel_to(date)
  end

  shared_examples 'creates matching bank transaction' do
    it 'creates one matching bank transaction' do
      expect { subject }.to change(Ticketing::BankTransaction, :count).by(1)
      t = Ticketing::BankTransaction.last
      expect(t.raw_source).to eq(transaction_details)
      expect(t.raw_source_sha).to eq(sha)
    end
  end

  shared_examples 'matches transaction' do
    it_behaves_like 'creates matching bank transaction'

    it 'marks the order as paid' do
      expect { subject }.to(change { order.reload.paid }.to(true))
    end

    it 'settles the order\'s balance' do
      expect { subject }.to(change { order.reload.balance }.to(0))
    end

    it 'does not touch the other orders' do
      expect { subject }.not_to(change { orders[1..2].map { |o| o.reload.paid } })
    end
  end

  shared_examples 'does not match transaction' do
    it 'does not create any bank transactions' do
      expect { subject }.not_to change(Ticketing::BankTransaction, :count)
    end

    it 'does not touch the order' do
      expect { subject }.not_to(change { order.reload.updated_at })
    end
  end

  context 'without existing received bank transactions' do
    it 'fetches transactions starting a week ago' do
      expect(ebics).to receive(:transactions).with(date - 1.week)
      subject
    end
  end

  context 'with existing received bank transactions' do
    let!(:existing_transaction) { create(:bank_transaction, :received) }

    it 'fetches transactions starting with the date of the last transaction' do
      expect(ebics).to receive(:transactions).with(existing_transaction.raw_source['date'].to_date)
      subject
    end
  end

  context 'with existing received bank transactions with same hash' do
    let!(:existing_transaction) { create(:bank_transaction, :received) }
    let(:sha) { existing_transaction.raw_source_sha }

    it_behaves_like 'does not match transaction'
  end

  context 'when transaction is a direct debit' do
    let(:mref) { 'foo' }

    it_behaves_like 'does not match transaction'
  end

  context 'when no transaction are returned from the bank' do
    let(:transactions) { [] }

    it_behaves_like 'does not match transaction'
  end

  it_behaves_like 'matches transaction'

  context 'with reference missing keyword' do
    let(:reference) { order.number.to_s }

    it_behaves_like 'matches transaction'
  end

  context 'with reference including too many numbers' do
    let(:reference) { "1#{order.number}" }

    it_behaves_like 'does not match transaction'
  end

  context 'with reference not matching anything' do
    let(:reference) { '987654' }

    it_behaves_like 'does not match transaction'
  end

  context 'when order is already paid' do
    let(:order) { create(:order, :complete) }

    it_behaves_like 'does not match transaction'
  end

  context 'when order balance does not match transaction amount' do
    let(:amount) { 999 }

    it_behaves_like 'does not match transaction'
  end

  context 'when two payments are combined into one' do
    let(:paid_orders) { orders[..1] }
    let(:amount) { -paid_orders.sum(&:balance) }
    let(:reference) { "Bestellungen #{paid_orders.pluck(:number).join(' ')} 999999" }
    let(:orders) do
      orders = super()
      orders[1].withdraw_from_account(123, nil)
      orders
    end

    it_behaves_like 'creates matching bank transaction'

    it 'marks the orders as paid' do
      expect { subject }.to(change { paid_orders.map { |o| o.reload.paid } }.to([true] * paid_orders.count))
    end

    it 'settles the orders\' balance' do
      expect { subject }.to(change { paid_orders.map { |o| o.reload.balance } }.to([0] * paid_orders.count))
    end

    it 'associates both orders with this new bank transaction' do
      subject
      expect(Ticketing::BankTransaction.last.orders).to eq(paid_orders)
    end

    it 'does not touch the other order' do
      expect { subject }.not_to(change { orders[2].reload.paid })
    end
  end
end
