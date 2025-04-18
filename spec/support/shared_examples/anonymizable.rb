# frozen_string_literal: true

require 'support/time'

RSpec.shared_examples 'anonymizable' do |columns|
  describe '.unanonymized' do
    subject { described_class.unanonymized }

    let!(:anonymized) do
      record = records.first
      record.anonymize!
      record
    end
    let!(:unanonymized) { records.second }

    it 'only includes anonymized records' do
      expect(subject).not_to include(anonymized)
      expect(subject).to include(unanonymized)
    end
  end

  describe '#anonymize!' do
    subject { record.anonymize! }

    it 'clears all anonymizable columns' do
      columns.each do |column|
        expect(record.public_send(column)).not_to be_nil
      end
      subject
      columns.each do |column|
        expect(record.public_send(column)).to be_nil
      end
    end

    it 'sets anonymized_at' do
      freeze_time do
        expect { subject }.to change(record, :anonymized_at).to(Time.current)
      end
    end
  end

  describe '#anonymized?' do
    it 'reflects anonymization state' do
      expect { record.anonymize! }.to change(record, :anonymized?).to(true)
    end
  end
end

RSpec.shared_examples 'non-anonymizable order' do |order_factory|
  describe '#anonymize!' do
    subject { order.anonymize! }

    let(:order) { create(order_factory, :with_tickets, tickets_count: 1) }

    before { order.tickets.first.date.update(date: 7.weeks.ago) }

    it 'does not anonymize this type of order' do
      expect { subject }.not_to(change { order.reload.attributes })
    end
  end
end
