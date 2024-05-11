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
end
