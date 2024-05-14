# frozen_string_literal: true

RSpec.describe Ticketing::ProcessReceivedTransferPaymentsJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    let(:service) { instance_double(Ticketing::ReceivedTransferPaymentProcessService, execute: true) }

    before do
      allow(Settings.ebics).to receive(:enabled).and_return(enabled)
      allow(Ticketing::ReceivedTransferPaymentProcessService).to receive(:new).and_return(service)
    end

    context 'with EBICS enabled' do
      let(:enabled) { true }

      it 'calls the service' do
        expect(service).to receive(:execute)
        subject
      end
    end

    context 'with EBICS disabled' do
      let(:enabled) { false }

      it 'does not call the service' do
        expect(service).not_to receive(:execute)
        subject
      end
    end
  end
end
