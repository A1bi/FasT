# frozen_string_literal: true

RSpec.describe Ticketing::BankSubmission do
  describe 'validatations' do
    subject { create(:bank_submission, :with_debits, transactions_count: 2) }

    before { subject.transactions[0].orders << create(:order, :complete) }

    context 'when some bank transactions lack orders' do
      it 'adds an error' do
        subject.validate
        expect(subject.errors).to be_added(:transactions, :transactions_without_orders)
      end
    end

    context 'when orders are present on all bank transactions' do
      before { subject.transactions[1].orders << create(:order, :complete) }

      it { is_expected.to be_valid }
    end
  end
end
