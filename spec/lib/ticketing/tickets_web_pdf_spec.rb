# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.describe Ticketing::TicketsWebPdf do
  let(:event) { build(:event, :complete) }
  let(:tickets_count) { 1 }
  let(:order) do
    create(:order, :with_tickets, tickets_count: tickets_count, event: event)
  end
  let(:ticket_medium) { 'web' }
  let(:page_layout) { [595.28, 841.89] }

  let(:tickets_pdf) { described_class.new }
  let(:pdf) do
    tickets_pdf.add_tickets(order.tickets)
    tickets_pdf.render
  end
  let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(pdf) }

  let(:images_path) { Rails.root.join('app/assets/images') }
  let(:logo_path) { images_path.join('pdf/logo_bw.svg') }
  let(:event_header_path) do
    images_path.join("theater/#{event.identifier}/ticket_header.svg")
  end

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

  shared_examples 'renders the correct information' do
    def unauthenticated_content(index)
      "#{Settings.ticket_barcode_base_url}barcode_#{index}"
    end

    def authenticated_content(index)
      "#{Settings.ticket_barcode_base_url}barcode_authenticated_#{index}"
    end

    it 'renders the correct event information' do
      expect(text_analysis.strings)
        .to include(event.location).exactly(tickets_count).times
    end

    it 'renders the correct ticket information' do
      order.tickets.each.with_index do |ticket, i|
        expect(page_analysis.pages[i / 3][:strings])
          .to include(ticket.number, ticket.type.name)
      end
    end

    it 'renders the correct ticket barcodes' do
      order.tickets.size.times do |i|
        expect(tickets_pdf).to receive(:print_qr_code)
          .with(unauthenticated_content(i), any_args).once
        expect(tickets_pdf).not_to receive(:print_qr_code)
          .with(authenticated_content(i), any_args)
        expect(tickets_pdf).to receive(:link_annotate)
          .with(authenticated_content(i), any_args).once
      end
      pdf
    end
  end

  it 'renders the correct event header' do
    expect(File).to receive(:read).with(event_header_path)
    pdf
  end

  context 'with one ticket' do
    include_examples 'all pages have the correct layout'
    include_examples 'renders the correct information'
  end

  context 'with three tickets' do
    let(:tickets_count) { 3 }

    include_examples 'renders the correct information'
  end

  context 'with four tickets' do
    let(:tickets_count) { 4 }

    include_examples 'all pages have the correct layout'
    include_examples 'renders the correct information'
  end

  context 'with nine tickets' do
    let(:tickets_count) { 9 }

    include_examples 'renders the correct information'
  end
end
