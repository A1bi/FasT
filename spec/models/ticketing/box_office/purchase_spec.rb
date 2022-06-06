# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::Purchase do
  describe '#totals_by_vat_rate' do
    subject { purchase.totals_by_vat_rate }

    let(:purchase) { described_class.new }
    let(:tickets) { build_list(:ticket, 2) }
    let(:product1) { build(:box_office_product, price: 3.44, vat_rate: :standard) }
    let(:product2) { build(:box_office_product, price: 12.34, vat_rate: :zero) }
    let(:order_payment) { build(:box_office_order_payment, amount: 7.22) }
    let(:expected_totals) do
      {
        standard: {
          net: 5.78,
          vat: 1.1,
          gross: 6.88
        },
        reduced: {
          net: 11.92,
          vat: 0.83,
          gross: 12.75
        },
        zero: {
          net: 12.34,
          vat: 0,
          gross: 12.34
        },
        total: {
          net: 30.04,
          vat: 1.93,
          gross: 31.97
        }
      }
    end

    before do
      tickets[0].price = 3.21
      tickets[1].price = 2.32
      purchase.items.new(number: 1, purchasable: tickets[0])
      purchase.items.new(number: 1, purchasable: tickets[1])
      purchase.items.new(number: 2, purchasable: product1)
      purchase.items.new(number: 1, purchasable: product2)
      purchase.items.new(number: 1, purchasable: order_payment)

      [order_payment, *tickets].each do |instance|
        allow(instance).to receive(:vat_rate).and_return(:reduced)
      end
    end

    it 'returns the correct VAT totals' do
      expect(subject).to eq(expected_totals)
    end
  end
end
