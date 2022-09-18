# frozen_string_literal: true

RSpec.describe Ticketing::BankSubmissionZipService do
  describe '#zip' do
    subject { Zip::File.open_buffer(service.zip) }

    let(:service) { described_class.new(submission) }
    let(:files) { subject.entries.map(&:name) }

    context 'with debits' do
      let(:submission) { create(:bank_submission, :with_debits) }

      it 'only contains the debits file' do
        expect(files).to contain_exactly('debits.xml')
      end
    end

    context 'with refunds' do
      let(:submission) { create(:bank_submission, :with_refunds) }

      it 'only contains the transfers file' do
        expect(files).to contain_exactly('transfers.xml')
      end
    end

    context 'with both debits and refunds' do
      let(:submission) { create(:bank_submission, :with_debits, :with_refunds) }

      it 'contains both debits and transfers file' do
        expect(files).to contain_exactly('debits.xml', 'transfers.xml')
      end
    end
  end
end
