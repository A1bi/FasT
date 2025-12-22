# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::ReceivedTransferPaymentProcessService do
  subject { service.execute(intraday:) }

  let(:service) { described_class.new }
  let(:intraday) { false }
  let(:ebics) do
    instance_double(Ticketing::EbicsService,
                    statement_entries: entries, intraday_entries: entries)
  end
  let(:entries) { [entry_debit, entry] }
  let(:entry_debit) do
    instance_double(SepaFileParser::Entry,
                    credit?: false, transactions: [entry_debit_transaction], xml_data:)
  end
  let(:entry_debit_transaction) do
    instance_double(SepaFileParser::Transaction, mandate_reference: 'foomanref')
  end
  let(:entry) do
    instance_double(SepaFileParser::Entry,
                    credit?: true, amount: amount.to_f, name: 'Johnny Doe', iban: 'DE75512108001245126199',
                    remittance_information: reference, bank_reference:,
                    transactions: entry_transactions, xml_data:)
  end
  let(:entry_transactions) { [entry_transaction] }
  let(:entry_transaction) do
    instance_double(SepaFileParser::Transaction, mandate_reference:)
  end
  let(:amount) { -order.balance }
  let(:reference) { "Bestellung #{order.number}" }
  let(:bank_reference) { 'fooref' }
  let(:mandate_reference) { '' }
  let(:xml_data) { Nokogiri::XML.parse('<Ntry><foo>bar</foo></Ntry>') }
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
      expect(t.camt_source).to eq('foo' => 'bar')
    end
  end

  shared_examples 'matches entry' do
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

  shared_examples 'does not match entry' do
    it 'does not create any bank transactions' do
      expect { subject }.not_to change(Ticketing::BankTransaction, :count)
    end

    it 'does not touch the order' do
      expect { subject }.not_to(change { order.reload.updated_at })
    end
  end

  context 'without existing received bank transactions' do
    it 'fetches transactions starting a week ago' do
      expect(ebics).to receive(:statement_entries).with(date - 1.week)
      subject
    end
  end

  context 'with existing received bank transactions' do
    let!(:existing_transaction) { create(:bank_transaction, :received) }

    it 'fetches transactions starting with the date of the last transaction' do
      expect(ebics).to receive(:statement_entries).with(existing_transaction.camt_source['BookgDt']['Dt'].to_date)
      subject
    end
  end

  context 'with existing received bank transactions with same bank_reference' do
    before { create(:bank_transaction, :received, bank_reference:) }

    it_behaves_like 'does not match entry'
  end

  context 'when entry is credit but actually the result of a debit performed by us' do
    let(:mandate_reference) { 'fooref' }

    it_behaves_like 'does not match entry'
  end

  context 'when entry has more than one transaction' do
    let(:entry_transactions) { [entry_transaction, entry_transaction] }

    it_behaves_like 'does not match entry'

    it 'creates a Sentry report' do
      expect(Sentry).to receive(:capture_message)
        .with('bank statement entry does not contain exactly one transaction',
              extra: { entry_bank_reference: entry.bank_reference })
      subject
    end
  end

  context 'when no entries are returned from the bank' do
    let(:entries) { [] }

    it_behaves_like 'does not match entry'
  end

  it_behaves_like 'matches entry'

  context 'with reference missing keyword' do
    let(:reference) { order.number.to_s }

    it_behaves_like 'matches entry'
  end

  context 'with reference including too many numbers' do
    let(:reference) { "1#{order.number}" }

    it_behaves_like 'does not match entry'
  end

  context 'with reference not matching anything' do
    let(:reference) { '987654' }

    it_behaves_like 'does not match entry'
  end

  context 'when order is already paid' do
    let(:order) { create(:order, :complete) }

    it_behaves_like 'does not match entry'
  end

  context 'when order balance does not match transaction amount' do
    let(:amount) { 999 }

    it_behaves_like 'does not match entry'
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

  context 'when reference is missing' do
    let(:reference) { nil }

    it_behaves_like 'does not match entry'
  end

  context 'when daily is requested' do
    it 'fetches daily entries' do
      expect(ebics).to receive(:statement_entries)
      subject
    end
  end

  context 'when intraday is requested' do
    let(:intraday) { true }

    it 'fetches intraday entries' do
      expect(ebics).to receive(:intraday_entries).with(no_args)
      subject
    end
  end
end
