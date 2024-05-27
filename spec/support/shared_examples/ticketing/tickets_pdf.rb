# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.shared_context 'when rendering tickets pdf' do
  let(:event) { build(:event, :complete) }
  let(:tickets_count) { 1 }
  let(:order) { create(:order, :with_tickets, tickets_count:, event:) }

  let(:tickets_pdf) { described_class.new }
  let(:pdf) do
    tickets_pdf.add_tickets(order.tickets)
    tickets_pdf.render
  end
  let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(pdf) }

  let(:images_path) { Rails.root.join('app/assets/images') }
  let(:logo_path) { images_path.join('pdf/logo_bw_l3.svg') }
  let(:event_logo_path) { images_path.join("events/#{event.assets_identifier}/title.svg") }

  before do
    # speed up PDF generation by skipping barcode
    allow(tickets_pdf).to receive(:print_qr_code)
    allow(tickets_pdf).to receive(:link_annotate).with(any_args)

    order.tickets.each.with_index do |ticket, i|
      allow(ticket).to receive(:signed_info)
        .with(medium: ticket_medium, authenticated: false)
        .and_return("barcode_#{i}")

      allow(ticket).to receive(:signed_info)
        .with(medium: nil, authenticated: true)
        .and_return("barcode_authenticated_#{i}")
    end
  end

  include_context 'when loading of SVG files'

  def unauthenticated_content(index)
    "#{Settings.ticketing.ticket_barcode_base_url}barcode_#{index}"
  end

  def authenticated_content(index)
    "#{Settings.ticketing.ticket_barcode_base_url}barcode_authenticated_#{index}"
  end
end

RSpec.shared_examples 'renders the correct event information' do
  it 'renders the correct event information' do
    expect(text_analysis.strings).to include(event.location.address).exactly(tickets_count).times
  end
end

RSpec.shared_examples 'tickets pdf renderer' do
  context 'with existing event logo' do
    before do
      allow(tickets_pdf).to receive(:event_logo_path).with(event).and_return(event_logo_path)
    end

    it 'renders the event logo' do
      expect(File).to receive(:read).with(event_logo_path)
      pdf
    end
  end

  context 'without existing event logo' do
    it 'renders the event logo' do
      expect(File).not_to receive(:read).with(event_logo_path)
      pdf
    end
  end

  context 'with one ticket' do
    include_examples 'all pages have the correct layout'
    include_examples 'renders the correct event information'
    include_examples 'renders the correct ticket information'
  end

  context 'with three tickets' do
    let(:tickets_count) { 3 }

    include_examples 'renders the correct ticket information'
  end

  context 'with four tickets' do
    let(:tickets_count) { 4 }

    include_examples 'all pages have the correct layout'
    include_examples 'renders the correct event information'
    include_examples 'renders the correct ticket information'
  end

  context 'with nine tickets' do
    let(:tickets_count) { 9 }

    include_examples 'renders the correct ticket information'
  end

  context 'with a cancelled ticket' do
    let(:tickets_count) { 2 }
    let(:cancelled_ticket) { order.tickets.last }

    before { create(:cancellation, tickets: order.tickets.last(1)) }

    it 'does not render the cancelled ticket' do
      expect(text_analysis.strings).to include(order.tickets.first.number)
      expect(text_analysis.strings).not_to include(order.tickets.last.number)
    end
  end
end
