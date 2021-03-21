# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.describe Ticketing::CouponPdf do
  let(:coupon) { create(:coupon, :with_credit, value: 12.34) }
  let(:theme) { :generic }
  let(:pdf) { described_class.new(coupon, theme: theme).render }
  let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(pdf) }
  let(:page_layout) { [841.89, 595.28] }
  let(:images_path) { Rails.root.join('app/assets/images') }

  include_context 'when loading of SVG files'

  include_examples 'it has the correct number of pages', 1
  include_examples 'all pages have the correct layout'

  it 'contains the correct coupon information' do
    expect(text_analysis.strings)
      .to include('Gutschein', coupon.code, '12,34 ', '€')
  end

  context 'with generic theme' do
    it 'renders a bow' do
      path = images_path.join('pdf/coupon/bow.svg')
      expect(File).to receive(:read).with(path)
      pdf
    end
  end

  context 'with christmas theme' do
    let(:theme) { :christmas }

    it 'renders christmas front' do
      path = images_path.join('pdf/coupon/christmas_front.svg')
      expect(File).to receive(:read).with(path)
      pdf
    end
  end
end
