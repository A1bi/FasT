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
                    credit?: true, amount:,
                    sepa: { 'SVWZ' => reference }, to_h: transaction_details)
  end
  let(:transaction_details) { { 'name' => 'Johnny Doe', 'iban' => 'DE75512108001245126199', 'amount' => amount.to_f } }
  let(:amount) { -order.balance }
  let(:reference) { "Bestellung #{order.number}" }
  let(:order) { create(:order, :complete, :unpaid, :with_balance) }
  let(:date) { Date.parse('2024-05-11') }

  before do
    allow(Ticketing::EbicsService).to receive(:new).and_return(ebics)
    travel_to(date)
  end

  shared_examples 'matches transaction' do
    it 'creates a matching bank transaction' do
      expect { subject }.to change(Ticketing::BankTransaction, :count).by(1)
      t = Ticketing::BankTransaction.last
      expect(t.raw_source).to eq(transaction_details)
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
      expect(ebics).to receive(:transactions).with(existing_transaction.created_at.to_date)
      subject
    end
  end

  context 'when no transaction are returned from the bank' do
    let(:transactions) { [] }

    include_examples 'does not match transaction'
  end

  include_examples 'matches transaction'

  context 'with reference missing keyword' do
    let(:reference) { order.number.to_s }

    include_examples 'matches transaction'
  end

  context 'with reference including too many numbers' do
    let(:reference) { "1#{order.number}" }

    include_examples 'does not match transaction'
  end

  context 'with reference not matching anything' do
    let(:reference) { '987654' }

    include_examples 'does not match transaction'
  end

  context 'when order is already paid' do
    let(:order) { create(:order, :complete) }

    include_examples 'does not match transaction'
  end

  context 'when order balance does not match transaction amount' do
    let(:amount) { 999 }

    include_examples 'does not match transaction'
  end
end
