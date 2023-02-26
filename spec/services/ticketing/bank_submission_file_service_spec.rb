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

      before { Zip.force_entry_names_encoding = 'UTF-8' }

      let(:submission) { create(:bank_submission, :with_debits, :with_refunds) }
      let(:files) { subject.entries.map(&:name) }

      it 'contains both debits and transfers file' do
        expect(files).to contain_exactly('Lastschriften.xml', 'Überweisungen.xml')
      end
    end
  end

  describe '#file_name' do
    subject { service.file_name }

    context 'with debits' do
      let(:submission) { create(:bank_submission, :with_debits) }

      it { is_expected.to eq("Lastschriften-#{submission.id}.xml") }
    end

    context 'with refunds' do
      let(:submission) { create(:bank_submission, :with_refunds) }

      it { is_expected.to eq("Überweisungen-#{submission.id}.xml") }
    end

    context 'with both debits and refunds' do
      let(:submission) { create(:bank_submission, :with_debits, :with_refunds) }

      it { is_expected.to eq("SEPA-#{submission.id}.zip") }
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
