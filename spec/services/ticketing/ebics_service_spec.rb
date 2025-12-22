# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::EbicsService do
  let(:service) { described_class.new }
  let(:client) { instance_double(Epics::Client) }
  let(:today) { Date.parse('2024-05-10') }
  let(:date) { today - 1.day }
  let(:entry) { instance_double(SepaFileParser::Entry) }
  let(:file) { instance_double(Pathname, open: 'foo') }
  let(:credentials) { ActiveSupport::OrderedOptions.new }

  before do
    allow(Rails.root).to receive(:join).with('config/ebics.key').and_return(file)
    allow(Rails.application.credentials).to receive(:ebics).and_return(credentials)
    allow(Epics::Client).to receive(:new).and_return(client)
    travel_to(today)
  end

  shared_context 'when fetching data' do
    before do
      allow(SepaFileParser::String).to receive(:parse).with('foo').and_return(document, document)
      allow(client).to receive(order_type).with(date, today).and_return(%w[foo foo])
    end
  end

  shared_examples 'error handling' do
    let(:error) { Epics::Error::BusinessError.new(error_code) }

    before { allow(client).to receive(order_type).and_raise(error) }

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

  describe '#statement_entries' do
    subject { service.statement_entries(date) }

    let(:order_type) { :C53 }
    let(:document) { instance_double(SepaFileParser::Camt053::Base, statements: [statement, statement]) }
    let(:statement) { instance_double(SepaFileParser::Camt053::Statement, entries: [entry]) }

    include_context 'when fetching data'

    it 'returns statement entries' do
      expect(subject).to contain_exactly(entry, entry, entry, entry)
    end

    it_behaves_like 'error handling'
  end

  describe '#intraday_entries' do
    subject { service.intraday_entries }

    let(:order_type) { :C52 }
    let(:date) { today }
    let(:document) { instance_double(SepaFileParser::Camt052::Base, reports: [report, report]) }
    let(:report) { instance_double(SepaFileParser::Camt052::Report, entries: [entry]) }

    include_context 'when fetching data'

    it 'returns intraday entries' do
      expect(subject).to contain_exactly(entry, entry, entry, entry)
    end

    it_behaves_like 'error handling'
  end

  describe '#submit_debits' do
    subject { service.submit_debits('foo') }

    before { allow(client).to receive(:debit).and_return('bar') }

    it 'calls the right client method' do
      expect(client).to receive(:debit).with('foo')
      subject
    end

    it 'returns the response' do
      expect(subject).to eq('bar')
    end
  end

  describe '#submit_transfers' do
    subject { service.submit_transfers('foo') }

    before { allow(client).to receive(:credit).and_return('bar') }

    it 'calls the right client method' do
      expect(client).to receive(:credit).with('foo')
      subject
    end

    it 'returns the response' do
      expect(subject).to eq('bar')
    end
  end
end
