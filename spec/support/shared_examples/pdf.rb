# frozen_string_literal: true

RSpec::Matchers.define :an_svg_file do
  match { |path| path.to_s.match?(/.+\.svg\z/) }
end

RSpec.shared_context 'when loading of SVG files' do
  before do
    allow(File).to receive(:read).with(an_svg_file).and_return('<svg></svg>')
  end
end

RSpec.shared_examples 'it has the correct number of pages' do |pages|
  it "has #{pages} page" do
    expect(page_analysis.pages.size).to eq(pages)
  end
end

RSpec.shared_examples 'all pages have the correct layout' do
  it 'all pages have the correct layout' do
    expect(page_analysis.pages.pluck(:size)).to all(eq(page_layout))
  end
end
