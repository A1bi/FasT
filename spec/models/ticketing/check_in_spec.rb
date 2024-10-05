# frozen_string_literal: true

RSpec.describe Ticketing::CheckIn do
  describe 'associations' do
    it { is_expected.to belong_to(:ticket) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:medium) }
    it { is_expected.to validate_presence_of(:date) }
  end

  describe '#retroactive?' do
    subject { check_in.retroactive? }

    let(:order) { create(:web_order, :with_tickets) }
    let(:check_in) { build(:check_in, ticket: order.tickets.first, date:) }
    let(:date) { order.date.date - 1.hour }

    it { is_expected.to be_falsy }

    context 'when check-in date is much later than event date' do
      let(:date) { order.date.date + 3.hours }

      it { is_expected.to be_truthy }
    end
  end
end
