# frozen_string_literal: true

require_shared_examples 'ticketing/billable'
require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::Coupon do
  it {
    expect(subject)
      .to define_enum_for(:value_type).with_values(free_tickets: 'free_tickets',
                                                   credit: 'credit')
                                      .with_suffix(:value)
                                      .backed_by_column_of_type(:enum)
  }

  describe 'associations' do
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
        create(:coupon, :free_tickets),
        create(:coupon, :credit)
      ]
    end
    let!(:expired_coupons) do
      [
        create(:coupon, :blank),
        create(:coupon, :free_tickets, :expired)
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

    let(:coupon) { create(:coupon) }
    let(:coupon2) { create(:coupon) }

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
        let(:coupon) { create(:coupon, :free_tickets, :expired) }

        it { is_expected.to be_truthy }
      end
    end

    context 'without any value' do
      let(:coupon) { create(:coupon, :blank) }

      it { is_expected.to be_truthy }
    end

    context 'with free tickets' do
      let(:coupon) { create(:coupon, :free_tickets) }

      it_behaves_like 'valid coupon'
    end

    context 'with credit' do
      let(:coupon) { create(:coupon, :credit) }

      it_behaves_like 'valid coupon'
    end
  end

  describe '#value' do
    subject { coupon.value }

    let(:coupon) { create(:coupon, value: 44) }

    it { is_expected.to eq(44) }

    context 'when value changes' do
      before { coupon.withdraw_from_account(10, :foo) }

      it { is_expected.to eq(34) }
    end
  end

  describe '#initial_value' do
    subject { coupon.initial_value }

    let(:coupon) { create(:coupon, value: 44) }

    context 'when coupon never had any value' do
      let(:coupon) { create(:coupon, :blank) }

      it { is_expected.to eq(0) }
    end

    context 'when coupon has not been redeemed yet' do
      it { is_expected.to eq(44) }
    end

    context 'when coupon has been redeemed at least partially' do
      before { coupon.withdraw_from_account(10, :foo) }

      it { is_expected.to eq(44) }
    end
  end

  describe '#free_tickets' do
    subject { coupon.free_tickets }

    context 'when coupon is not of type free_tickets' do
      let(:coupon) { create(:coupon, :credit, value: 25) }

      it { is_expected.to eq(0) }
    end

    context 'when coupon is of type free_tickets and has value' do
      let(:coupon) { create(:coupon, :free_tickets, value: 2) }

      it { is_expected.to eq(2) }
      it { is_expected.to be_a(Integer) }
    end

    context 'when coupon is of type free_tickets and has no value' do
      let(:coupon) { create(:coupon, :free_tickets, :blank) }

      it { is_expected.to eq(0) }
    end
  end

  describe '#credit' do
    subject { coupon.credit }

    context 'when coupon is not of type credit' do
      let(:coupon) { create(:coupon, :free_tickets, value: 2) }

      it { is_expected.to eq(0) }
    end

    context 'when coupon is of type credit and has value' do
      let(:coupon) { create(:coupon, :credit, value: 25) }

      it { is_expected.to eq(25) }
      it { is_expected.to be_a(BigDecimal) }
    end

    context 'when coupon is of type credit and has no value' do
      let(:coupon) { create(:coupon, :credit, :blank) }

      it { is_expected.to eq(0) }
    end
  end

  it_behaves_like 'billable'
  it_behaves_like 'loggable'
end
