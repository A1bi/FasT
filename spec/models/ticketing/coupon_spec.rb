# frozen_string_literal: true

require_shared_examples 'ticketing/billable'
require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::Coupon do
  describe 'associations' do
    it {
      expect(subject)
        .to have_and_belong_to_many(:reservation_groups)
        .join_table(:ticketing_coupons_reservation_groups)
    }

    it {
      expect(subject)
        .to have_many(:redemptions).class_name('Ticketing::CouponRedemption')
                                   .dependent(:destroy)
    }

    it {
      expect(subject)
        .to belong_to(:purchased_with_order).class_name('Ticketing::Order')
                                            .optional(true)
    }

    it { is_expected.to have_many(:orders).through(:redemptions) }
  end

  describe 'valid/expired scopes' do
    let!(:valid_coupons) do
      [
        create(:coupon, :with_free_tickets),
        create(:coupon, :with_credit)
      ]
    end
    let!(:expired_coupons) do
      [
        create(:coupon),
        create(:coupon, :with_free_tickets, :expired)
      ]
    end

    describe '.valid' do
      subject { described_class.valid }

      it 'only returns valid coupons' do
        expect(subject).to include(*valid_coupons)
        expect(subject).not_to include(*expired_coupons)
      end
    end

    describe '.expired' do
      subject { described_class.expired }

      it 'only returns expired coupons' do
        expect(subject).to include(*expired_coupons)
        expect(subject).not_to include(*valid_coupons)
      end
    end
  end

  describe '#code' do
    subject { coupon.code }

    let(:coupon) { described_class.create }
    let(:coupon2) { described_class.create }

    it { is_expected.not_to be_empty }

    it 'generates different codes' do
      expect(subject).not_to eq(coupon2.code)
    end
  end

  describe '#expired?' do
    subject { coupon.expired? }

    shared_examples 'valid coupon' do
      it { is_expected.to be_falsy }

      context 'with an expired date' do
        let(:coupon) { create(:coupon, :with_free_tickets, :expired) }

        it { is_expected.to be_truthy }
      end
    end

    context 'without any value' do
      let(:coupon) { create(:coupon) }

      it { is_expected.to be_truthy }
    end

    context 'with free tickets' do
      let(:coupon) { create(:coupon, :with_free_tickets) }

      it_behaves_like 'valid coupon'
    end

    context 'with credit' do
      let(:coupon) { create(:coupon, :with_credit) }

      it_behaves_like 'valid coupon'
    end
  end

  it_behaves_like 'billable'
  it_behaves_like 'loggable'
end
