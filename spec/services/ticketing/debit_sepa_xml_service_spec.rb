# frozen_string_literal: true

RSpec.describe Ticketing::DebitSepaXmlService do
  describe '#xml' do
    subject { service.xml }

    let(:service) { described_class.new(submission) }
    let(:submission) { create(:bank_submission, transactions:) }
    let(:transactions) { [debit_austria, debit_norway, refund] }
    let(:debit_austria) { create(:bank_debit, amount: 12.5, iban: 'AT483200000012345864') }
    let(:debit_norway) { create(:bank_debit, amount: 13, iban: 'NO8330001234567') }
    let(:refund) { create(:bank_refund, :submittable) }

    it 'includes all IBANs' do
      expect(subject).to include(debit_austria.iban, debit_norway.iban)
    end

    it 'includes all amounts' do
      expect(subject).to include('12.50', '13.00')
    end

    it 'set the correct note' do
      expect(subject).to include("Vielen Dank für Ihre Bestellung mit der Nummer #{debit_austria.order.number}")
    end

    it 'does not include refunds' do
      expect(subject).not_to include(refund.iban)
    end

    it 'sets the correct number of transactions and their sum' do
      expect(subject).to include('<NbOfTxs>2</NbOfTxs>', '<CtrlSum>25.50</CtrlSum>')
    end

    context 'without any debits' do
      let(:transactions) { [refund] }

      it { is_expected.to be_nil }
    end
  end
end
