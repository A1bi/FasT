# frozen_string_literal: true

RSpec.describe Ticketing::StripeTransaction do
  describe '#method' do
    subject { transaction.method }

    let(:order) { create(:web_order, :complete) }
    let!(:initial_payment) { create(:stripe_payment, method: :google_pay, order:) } # rubocop:disable RSpec/LetSetup

    context 'with a payment' do
      let(:transaction) { build(:stripe_payment, method: :apple_pay, order:) }

      it { is_expected.to eq('apple_pay') }
    end

    context 'with a refund with method' do
      let(:transaction) { build(:stripe_refund, method: :apple_pay, order:) }

      it { is_expected.to eq('apple_pay') }
    end

    context 'with a refund without method' do
      let(:transaction) { build(:stripe_refund, method: nil, order:) }

      it { is_expected.to eq('google_pay') }
    end

    context 'without an initial payment' do
      let!(:initial_payment) { nil }
      let(:transaction) { build(:stripe_refund, method: nil, order:) }

      it { is_expected.to be_nil }
    end
  end
end
