# frozen_string_literal: true

RSpec.describe Ticketing::CouponPdf do
  # speed up specs by using the same generated PDF for all examples
  before(:context) do
    @coupon = create(:coupon, amount: 12.34)
    @pdf = described_class.new(@coupon).render
  end

  after(:context) { @coupon.destroy }

  let(:text_analysis) { PDF::Inspector::Text.analyze(@pdf) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(@pdf) }

  it 'has one page' do
    expect(page_analysis.pages.size).to eq(1)
  end

  it 'has the correct layout' do
    expect(page_analysis.pages[0][:size]).to eq([841.89, 595.28])
  end

  it 'contains the correct coupon information' do
    expect(text_analysis.strings)
      .to include('Gutschein', @coupon.code, '12,34 ', '€')
  end
end
