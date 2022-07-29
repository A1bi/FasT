# frozen_string_literal: true

RSpec.describe Ticketing::AnonymizeOrdersJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    shared_examples 'does not anonymize order' do
      it 'does not anonymize the order' do
        expect { subject }.not_to(change { order.reload.attributes })
      end
    end

    shared_examples 'anonymizes order' do
      it 'anonymizes order' do
        expect { subject }.to change { order.reload.anonymized? }.to(true)
      end

      it 'anonymizes the corresponding bank charge' do
        expect { subject }.to change { order.bank_charge.reload.anonymized? }.to(true)
      end

      it 'anonymizes the corresponding bank refunds' do
        expect { subject }.to change { order.bank_refunds.first.reload.anonymized? }.to(true)
      end
    end

    context 'with an already anonymized order' do
      let(:order) { create(:web_order, :with_tickets, :anonymized) }

      include_examples 'does not anonymize order'
    end

    context 'when there is one date and it is at least 6 weeks past' do
      let(:order) do
        order = create(:web_order, :with_tickets, :charge_payment, :with_bank_refunds)
        order.tickets.first.date.update(date: 7.weeks.ago)
        order
      end

      include_examples 'anonymizes order'
    end

    context 'when there are multiple dates and all are at least 6 weeks past' do
      let(:order) do
        order = create(:web_order, :with_tickets, :charge_payment, :with_bank_refunds, tickets_count: 2)
        order.tickets.first.date.update(date: 7.weeks.ago)
        order.tickets.second.update(date: order.tickets.first.date.dup)
        order.tickets.second.date.update(date: 8.weeks.ago)
        order
      end

      include_examples 'anonymizes order'
    end

    context 'when at least one date is not 6 weeks past' do
      let(:order) do
        order = create(:web_order, :with_tickets, tickets_count: 2)
        order.tickets.first.update(date: order.tickets.first.date.dup)
        order.tickets.first.date.update(date: 7.weeks.ago)
        order
      end

      include_examples 'does not anonymize order'
    end

    context 'when no dates are 6 weeks past' do
      let(:order) { create(:web_order, :with_tickets) }

      include_examples 'does not anonymize order'
    end
  end
end
