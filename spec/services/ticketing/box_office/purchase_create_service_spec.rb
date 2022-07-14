# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::PurchaseCreateService do
  subject { service.execute }

  let(:service) { described_class.new(params, box_office) }
  let(:box_office) { create(:box_office) }
  let(:product) { create(:box_office_product) }
  let(:params) do
    {
      pay_method: :electronic_cash,
      items: [
        {
          type: 'product',
          id: product.id,
          number: 1
        }
      ]
    }
  end

  it 'creates a purchase' do
    expect { subject }.to change(Ticketing::BoxOffice::Purchase, :count).by(1)
  end

  it 'creates a purchase item' do
    expect { subject }.to change(Ticketing::BoxOffice::PurchaseItem, :count).by(1)
    expect(Ticketing::BoxOffice::Purchase.last.items.count).to eq(1)
  end

  it 'broadcasts to front displays' do
    expect { subject }.to(
      have_broadcasted_to(box_office).from_channel(Ticketing::BoxOffice::FrontDisplayChannel).with do |params|
        purchase = Ticketing::BoxOffice::Purchase.last
        expect(params[:id]).to eq(purchase.id)
        expect(params[:token]).to eq(purchase.receipt_token)
      end
    )
  end
end
