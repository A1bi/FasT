# frozen_string_literal: true

require_shared_examples 'ticketing/tickets_pdf'

RSpec.describe Ticketing::TicketsBoxOfficePdf do
  let(:ticket_medium) { 'box_office' }
  let(:page_layout) { [841.89, 595.28] }

  include_context 'when rendering tickets pdf'

  shared_examples 'renders the correct ticket information' do
    it 'renders the correct ticket information on the correct page' do
      order.tickets.each.with_index do |ticket, i|
        expect(page_analysis.pages[i][:strings]).to include(ticket.number, ticket.type.name)
      end
    end

    it 'renders the correct ticket barcodes' do
      order.tickets.each do |ticket|
        expect(tickets_pdf).to receive(:print_qr_code).with(unauthenticated_content(ticket), any_args).once
        expect(tickets_pdf).not_to receive(:print_qr_code).with(authenticated_content(ticket), any_args)
        expect(tickets_pdf).not_to receive(:link_annotate).with(authenticated_content(ticket), any_args)
      end
      pdf
    end
  end

  it_behaves_like 'tickets pdf renderer'
end
