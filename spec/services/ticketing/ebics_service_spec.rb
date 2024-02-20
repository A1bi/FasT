# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::EbicsService do
  let(:service) { described_class.new }
  let(:client) { instance_double(Epics::Client) }
  let(:date) { Date.parse('2024-05-10') }
  let(:today) { date + 1.day }
  let(:statement) { instance_double(Cmxl::Statement, transactions: [transaction]) }
  let(:transaction) { instance_double(Cmxl::Fields::Transaction) }

  before do
    allow(Epics::Client).to receive(:new).and_return(client)
    allow(client).to receive(:STA).with(date, today).and_return('foo')
    allow(Cmxl).to receive(:parse).with('foo', anything).and_return([statement, statement])
    travel_to(today)
  end

  describe '#statements' do
    subject { service.statements(date) }

    it 'returns statements' do
      expect(subject).to contain_exactly(statement, statement)
    end

    describe 'error handling' do
      let(:error) { Epics::Error::BusinessError.new(error_code) }

      before { allow(client).to receive(:STA).and_raise(error) }

      context 'when no statements available' do
        let(:error_code) { '090005' }

        it { is_expected.to be_empty }
      end

      context 'when other error occurs' do
        let(:error_code) { 'foo' }

        it 'raises an error' do
          expect { subject }.to raise_error(error)
        end
      end
    end
  end

  describe '#transactions' do
    subject { service.transactions(date) }

    it 'returns transactions' do
      expect(subject).to contain_exactly(transaction, transaction)
    end
  end
end
