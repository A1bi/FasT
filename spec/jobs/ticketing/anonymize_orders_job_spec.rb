# frozen_string_literal: true

RSpec.describe Ticketing::AnonymizeOrdersJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    let!(:anonymized) do
      create(:web_order, :with_tickets, :anonymized)
    end
    let!(:anonymizable) do
      order = create(:web_order, :with_tickets)
      order.tickets.first.date.update(date: 7.weeks.ago)
      order
    end
    let(:semianonymizable) do
      order = create(:web_order, :with_tickets)
      order.tickets.first.date = order.tickets.first.date.dup
      order.tickets.first.date.update(date: 7.weeks.ago)
      order
    end
    let(:unanonymizeable) { create(:web_order, :with_tickets) }

    it 'does not touch already anonymized orders' do
      expect { subject }.not_to(change { anonymized.reload.attributes })
    end

    it 'anonymizes orders with all dates at least 6 weeks past' do
      expect { subject }
        .to change { anonymizable.reload.anonymized? }.to(true)
    end

    it 'does not anonymize orders when at least one date is not 6 weeks past' do
      expect { subject }.not_to(change { semianonymizable.reload.attributes })
    end

    it 'does not anonymize orders when no dates are 6 weeks past' do
      expect { subject }.not_to(change { unanonymizeable.reload.attributes })
    end
  end
end
