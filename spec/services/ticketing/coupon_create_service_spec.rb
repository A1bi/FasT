# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::CouponCreateService do
  subject { service.execute }

  let(:order) { build(:order) }
  let(:service) { described_class.new(order, nil, { coupons: coupons }) }

  context 'with no coupons provided' do
    let(:coupons) { nil }

    it 'does not add any coupons' do
      expect { subject }.not_to change(order, :purchased_coupons)
    end
  end

  context 'with three coupons provided' do
    let(:coupons) do
      [
        { amount: 50, number: 1 },
        { amount: 10, number: 2 }
      ]
    end
    let(:loggable) { order.purchased_coupons.last }

    it 'adds three coupons' do
      expect { subject }.to change(order.purchased_coupons, :size).by(3)
    end

    it 'sets the correct amounts' do
      subject
      expect(order.purchased_coupons[0].amount).to eq(50)
      order.purchased_coupons[1..2].each do |coupon|
        expect(coupon.amount).to eq(10)
      end
    end

    include_examples 'creates a log event for a new record', :created
  end
end
