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

    let(:transaction) { create(:bank_transaction, :received, raw_source:) }
    let(:raw_source) do
      {
        'amount' => 123, 'sub_fields' => { 'foo' => 'bar' }, 'entry_date' => '2024-05-14', 'information' => 'foobar',
        'iban' => 'DE75512108001245126199', 'debit' => false, 'name' => 'John Doe', 'credit' => true,
        'sepa' => { '123' => '456' }
      }
    end
    let(:anonymized_raw_source) do
      {
        'amount' => 123, 'entry_date' => '2024-05-14', 'debit' => false, 'credit' => true
      }
    end

    before { allow(transaction).to receive(:orders).and_return(orders) }

    it 'removes all anonymizable information from raw_source' do
      expect { subject }.to change(transaction, :raw_source).from(raw_source).to(anonymized_raw_source)
    end

    context 'when not all orders are anonymized yet' do
      let(:all_orders_anonymized) { false }

      it 'does not change anything' do
        expect { subject }.not_to change(transaction, :attributes)
      end
    end
  end

  describe '#raw_source=' do
    subject { transaction.raw_source = source }

    let(:transaction) { described_class.new }
    let(:source_details) { { 'name' => 'foo', 'iban' => 'DE123', 'amount' => 123.45 } }
    let(:source) { instance_double(Cmxl::Fields::Transaction, to_h: source_details) }

    it 'updates the transaction from source' do
      expect { subject }.to(
        change(transaction, :name).to('foo')
        .and(change(transaction, :iban).to('DE123'))
        .and(change(transaction, :amount).to(123.45))
      )
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
end
