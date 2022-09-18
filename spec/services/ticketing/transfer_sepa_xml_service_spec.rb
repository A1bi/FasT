# frozen_string_literal: true

RSpec.describe Ticketing::TransferSepaXmlService do
  describe '#xml' do
    subject { service.xml }

    let(:service) { described_class.new(submission) }
    let(:submission) { create(:bank_submission, transactions:) }
    let(:transactions) { [refund1, refund2, debit] }
    let(:refund1) { create(:bank_refund, amount: -12.5, iban: 'AT483200000012345864') }
    let(:refund2) { create(:bank_refund, amount: -13, iban: 'NO8330001234567') }
    let(:debit) { create(:bank_debit, :with_amount) }

    it 'includes all IBANs' do
      expect(subject).to include(refund1.iban, refund2.iban)
    end

    it 'includes all amounts' do
      expect(subject).to include('12.50', '13.00')
    end

    it 'set the correct note' do
      expect(subject).to include("Erstattung zu Ihrer Bestellung mit der Nummer #{refund1.order.number}")
    end

    it 'does not include debits' do
      expect(subject).not_to include(debit.iban)
    end

    it 'sets the correct number of transactions and their sum' do
      expect(subject).to include('<NbOfTxs>2</NbOfTxs>', '<CtrlSum>25.50</CtrlSum>')
    end

    context 'without any transfers' do
      let(:transactions) { [debit] }

      it { is_expected.to be_nil }
    end
  end
end
