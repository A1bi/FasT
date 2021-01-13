# frozen_string_literal: true

RSpec.describe Ticketing::AnonymizeOrdersJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    shared_examples 'does not anonymize order' do
      it 'does not anonymize the order' do
        expect { subject }.not_to(change { order.reload.attributes })
      end
    end

    context 'with an already anonymized order' do
      let(:order) do
        create(:web_order, :with_tickets, :anonymized)
      end

      include_examples 'does not anonymize order'
    end

    context 'when all dates are at least 6 weeks past' do
      let(:order) do
        order = create(:web_order, :with_tickets, :charge_payment)
        order.tickets.first.date.update(date: 7.weeks.ago)
        order
      end

      it 'anonymizes orders with all dates at least 6 weeks past' do
        expect { subject }.to change { order.reload.anonymized? }.to(true)
      end

      it 'also anonymizes the corresponding bank charge' do
        expect { subject }
          .to change { order.bank_charge.reload.anonymized? }.to(true)
      end
    end

    context 'when at least one date is not 6 weeks past' do
      let(:order) do
        order = create(:web_order, :with_tickets)
        order.tickets.first.date = order.tickets.first.date.dup
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
