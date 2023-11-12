# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::TseTransactionJob do
  describe '#perform_now' do
    subject { described_class.perform_now(purchase:) }

    let(:purchase) { create(:box_office_purchase, :with_items) }
    let(:create_service) { instance_double(Ticketing::BoxOffice::TseTransactionCreateService, execute: true) }

    before do
      Settings.tse.enabled = tse_enabled
      allow(Ticketing::BoxOffice::TseTransactionCreateService)
        .to receive(:new).with(purchase).and_return(create_service)
    end

    context 'with TSE disabled' do
      let(:tse_enabled) { false }

      it 'does not execute the create service' do
        expect(create_service).not_to receive(:execute)
        subject
      end
    end

    context 'with TSE enabled' do
      let(:tse_enabled) { true }

      it 'executes the create service' do
        expect(create_service).to receive(:execute)
        subject
      end
    end
  end
end
