# frozen_string_literal: true

require_shared_examples 'anonymizable'

RSpec.describe Ticketing::BankTransaction do
  it_behaves_like 'anonymizable', %i[name iban] do
    let(:record) { create(:bank_transaction) }
    let(:records) { create_list(:bank_transaction, 2) }
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
