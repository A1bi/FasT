# frozen_string_literal: true

require_shared_examples 'anonymizable'

RSpec.describe Ticketing::BankTransaction do
  let(:orders) do
    [
      instance_double(Ticketing::Web::Order, anonymized?: true),
      instance_double(Ticketing::Web::Order, anonymized?: all_orders_anonymized)
    ]
  end
  let(:all_orders_anonymized) { true }

  it_behaves_like 'anonymizable', %i[name iban] do
    let(:record) { create(:bank_transaction) }
    let(:records) { create_list(:bank_transaction, 2) }

    before { [record, *records].each { |r| allow(r).to receive(:orders).and_return(orders) } }
  end

  describe '#anonymize!' do
    subject { transaction.anonymize! }

    let(:transaction) { create(:bank_transaction, :received, camt_source:) }
    let(:camt_source) do
      {
        'Amt' => 123, 'AcctSvcrRef' => 'foo', 'BookgDt' => { 'Dt' => '2025-12-17' },
        'NtryDtls' => { 'TxDtls' => { 'RmtInf' => 'fooo', 'RltdPties' => { 'foo' => 'bar' }, 'CdtDbtInd' => 'bar' } }
      }
    end
    let(:anonymized_camt_source) do
      {
        'Amt' => 123, 'AcctSvcrRef' => 'foo', 'BookgDt' => { 'Dt' => '2025-12-17' },
        'NtryDtls' => { 'TxDtls' => { 'CdtDbtInd' => 'bar' } }
      }
    end

    before { allow(transaction).to receive(:orders).and_return(orders) }

    it 'removes all anonymizable information from camt_source' do
      expect { subject }.to change(transaction, :camt_source).from(camt_source).to(anonymized_camt_source)
    end

    context 'when not all orders are anonymized yet' do
      let(:all_orders_anonymized) { false }

      it 'does not change anything' do
        expect { subject }.not_to change(transaction, :attributes)
      end
    end
  end

  describe '#camt_entry=' do
    subject { transaction.camt_entry = entry }

    let(:transaction) { described_class.new }
    let(:xml) { Nokogiri::XML.parse('<Ntry><foo>bar</foo></Ntry>') }
    let(:entry) do
      instance_double(SepaFileParser::Entry, name: 'foo', iban: 'DE123', amount: 123.45, xml_data: xml)
    end

    it 'updates the transaction from the entry' do
      expect { subject }.to(
        change(transaction, :name).to('foo')
        .and(change(transaction, :iban).to('DE123'))
        .and(change(transaction, :amount).to(123.45))
      )
    end

    it 'updates camt_source' do
      expect { subject }.to change(transaction, :camt_source).to('foo' => 'bar')
    end
  end

  describe '.open' do
    subject { described_class.open }

    let(:transaction) { create(:bank_transaction) }

    before do
      create(:bank_transaction, :received)
      create(:bank_transaction, :submitted)
    end

    it { is_expected.to contain_exactly(transaction) }
  end

  describe '.submittable' do
    subject { described_class.submittable }

    let(:transaction) { create(:bank_transaction, :with_amount) }

    before do
      create(:bank_transaction)
      create(:bank_transaction, :received)
      create(:bank_transaction, :submitted)
    end

    it { is_expected.to contain_exactly(transaction) }
  end

  describe '#open?' do
    subject { transaction.open? }

    context 'with a received transaction' do
      let(:transaction) { build(:bank_transaction, :received) }

      it { is_expected.to be_falsy }
    end

    context 'with a submitted transaction' do
      let(:transaction) { build(:bank_transaction, :submitted) }

      it { is_expected.to be_falsy }
    end

    context 'with an open transaction' do
      let(:transaction) { build(:bank_transaction) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#debit?' do
    subject { transaction.debit? }

    context 'with a received transaction' do
      let(:transaction) { build(:bank_transaction, :received, :with_amount) }

      it { is_expected.to be_falsy }
    end

    context 'with a positive amount' do
      let(:transaction) { build(:bank_debit, :with_amount) }

      it { is_expected.to be_truthy }
    end

    context 'with a negative amount' do
      let(:transaction) { build(:bank_refund, :with_amount) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#refund?' do
    subject { transaction.refund? }

    context 'with a received transaction' do
      let(:transaction) { build(:bank_transaction, :received, :with_amount) }

      it { is_expected.to be_falsy }
    end

    context 'with a positive amount' do
      let(:transaction) { build(:bank_debit, :with_amount) }

      it { is_expected.to be_falsy }
    end

    context 'with a negative amount' do
      let(:transaction) { build(:bank_refund, :with_amount) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#remittance_information' do
    subject { transaction.remittance_information }

    context 'with a received transaction' do
      let(:transaction) { build(:bank_transaction, :received, remittance_information: 'foorem') }

      it { is_expected.to eq('foorem') }
    end

    context 'with any other transaction' do
      let(:transaction) { build(:bank_transaction) }

      it { is_expected.to be_nil }
    end
  end
end
