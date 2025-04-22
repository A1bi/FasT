# frozen_string_literal: true

RSpec.describe Ticketing::AnonymizeOrdersJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    let(:order) { create(:web_order, :with_tickets, :charge_payment, tickets_count:) }
    let(:tickets_count) { 1 }

    shared_examples 'does not anonymize order' do
      it 'does not anonymize the order' do
        expect { subject }.not_to(change { order.reload.attributes })
      end

      it 'does not anonymize the corresponding bank transactions' do
        expect { subject }.not_to change { order.bank_transactions.reload.map(&:anonymized?).uniq }.from([false])
      end
    end

    shared_examples 'anonymizes order' do
      it 'anonymizes order' do
        expect { subject }.to change { order.reload.anonymized? }.to(true)
      end

      it 'anonymizes the corresponding bank transactions' do
        expect { subject }.to change { order.bank_transactions.reload.map(&:anonymized?).uniq }.to([true])
      end
    end

    context 'with an already anonymized order' do
      let(:order) { create(:web_order, :with_tickets, :charge_payment, :anonymized) }

      it_behaves_like 'does not anonymize order'
    end

    context 'when there is one date and it is at least 6 weeks past' do
      before { order.tickets.first.date.update(date: 7.weeks.ago) }

      it_behaves_like 'anonymizes order'

      context 'with unsettled billing' do
        before { order.billing_account.update(balance: 10) }

        it_behaves_like 'does not anonymize order'
      end
    end

    context 'when there are multiple dates and all are at least 6 weeks past' do
      let(:tickets_count) { 2 }

      before do
        order.tickets.first.date.update(date: 7.weeks.ago)
        order.tickets.second.update(date: order.tickets.first.date.dup)
        order.tickets.second.date.update(date: 8.weeks.ago)
      end

      it_behaves_like 'anonymizes order'
    end

    context 'when at least one date is not 6 weeks past' do
      let(:tickets_count) { 2 }

      before do
        order.tickets.first.update(date: order.tickets.first.date.dup)
        order.tickets.first.date.update(date: 7.weeks.ago)
      end

      it_behaves_like 'does not anonymize order'
    end

    context 'when no dates are 6 weeks past' do
      it_behaves_like 'does not anonymize order'
    end
  end
end
