# frozen_string_literal: true

RSpec.describe Ticketing::BankSubmissionFileService do
  let(:service) { described_class.new(submission) }

  describe '#file' do
    subject { service.file }

    context 'with debits' do
      let(:submission) { create(:bank_submission, :with_debits) }
      let(:xml_service) { instance_double(Ticketing::DebitSepaXmlService, xml: 'foo') }

      before { allow(Ticketing::DebitSepaXmlService).to receive(:new).with(submission).and_return(xml_service) }

      it 'returns the debit XML file' do
        expect(subject).to eq('foo')
      end
    end

    context 'with refunds' do
      let(:submission) { create(:bank_submission, :with_refunds) }
      let(:xml_service) { instance_double(Ticketing::TransferSepaXmlService, xml: 'foo') }

      before { allow(Ticketing::TransferSepaXmlService).to receive(:new).with(submission).and_return(xml_service) }

      it 'returns the transfer XML file' do
        expect(subject).to eq('foo')
      end
    end

    context 'with both debits and refunds' do
      subject { Zip::File.open_buffer(service.file) }

      let(:submission) { create(:bank_submission, :with_debits, :with_refunds) }
      let(:files) { subject.entries.map(&:name) }

      it 'contains both debits and transfers file' do
        expect(files).to contain_exactly('debits.xml', 'transfers.xml')
      end
    end
  end

  describe '#file_name' do
    subject { service.file_name }

    context 'with debits' do
      let(:submission) { create(:bank_submission, :with_debits) }

      it { is_expected.to eq("debits-#{submission.id}.xml") }
    end

    context 'with refunds' do
      let(:submission) { create(:bank_submission, :with_refunds) }

      it { is_expected.to eq("transfers-#{submission.id}.xml") }
    end

    context 'with both debits and refunds' do
      let(:submission) { create(:bank_submission, :with_debits, :with_refunds) }

      it { is_expected.to eq("sepa-#{submission.id}.zip") }
    end
  end

  describe '#file_type' do
    subject { service.file_type }

    context 'with debits' do
      let(:submission) { create(:bank_submission, :with_debits) }

      it { is_expected.to eq('application/xml') }
    end

    context 'with refunds' do
      let(:submission) { create(:bank_submission, :with_refunds) }

      it { is_expected.to eq('application/xml') }
    end

    context 'with both debits and refunds' do
      let(:submission) { create(:bank_submission, :with_debits, :with_refunds) }

      it { is_expected.to eq('application/zip') }
    end
  end
end
