# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.describe Ticketing::CouponPdf do
  let(:coupon) { create(:coupon, amount: 12.34) }
  let(:pdf) { described_class.new(coupon).render }
  let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(pdf) }
  let(:page_layout) { [841.89, 595.28] }

  include_examples 'stub loading of SVG files'

  include_examples 'it has the correct number of pages', 1
  include_examples 'all pages have the correct layout'

  it 'contains the correct coupon information' do
    expect(text_analysis.strings)
      .to include('Gutschein', coupon.code, '12,34 ', '€')
  end
end
