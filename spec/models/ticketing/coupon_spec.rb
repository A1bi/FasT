# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::Coupon do
  describe 'associations' do
    it {
      is_expected
        .to have_and_belong_to_many(:reservation_groups)
        .join_table(:ticketing_coupons_reservation_groups)
    }
    it {
      is_expected
        .to have_many(:redemptions).class_name('Ticketing::CouponRedemption')
                                   .dependent(:destroy)
    }
    it { is_expected.to have_many(:orders).through(:redemptions) }
  end

  describe '#code' do
    let(:coupon) { described_class.create }
    let(:coupon2) { described_class.create }

    subject { coupon.code }

    it { is_expected.not_to be_empty }

    it 'generates different codes' do
      expect(subject).not_to eq(coupon2.code)
    end
  end

  describe '#expired?' do
    subject { coupon.expired? }

    context 'without any value' do
      let(:coupon) { create(:coupon) }

      it { is_expected.to be_truthy }
    end

    context 'with free tickets' do
      let(:coupon) { create(:coupon, :with_free_tickets) }

      it { is_expected.to be_falsy }

      context 'with an expired date' do
        let(:coupon) { create(:coupon, :with_free_tickets, :expired) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#redeem' do
    let(:coupon) { create(:coupon) }
    let(:loggable) { coupon }

    subject do
      coupon.redeem
      coupon.save
    end

    include_examples 'creates a log event', :redeemed
  end

  it_behaves_like 'loggable'
end
