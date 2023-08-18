# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.describe Ticketing::BoxOffice::PurchaseReceiptPdf do
  subject do
    pdf.purchase = purchase
    pdf.render
  end

  let(:order) { create(:order, :with_tickets, tickets_count: 2) }
  let(:tickets) { order.tickets }
  let(:purchase) { build(:box_office_purchase, :with_tse_device, total: 7.87, box_office:, tse_info:) }
  let(:box_office) { build(:box_office, id: 67, tse_client_id: 'fooby') }
  let(:product) { create(:box_office_product, price: 1.23, vat_rate: :standard) }
  let(:order_payment) { create(:box_office_order_payment, order:, amount: 1.11) }
  let(:pdf) { described_class.new }
  let(:text_analysis) { PDF::Inspector::Text.analyze(subject) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(subject) }
  let(:tse_info) do
    {
      'process_type' => 'receipy',
      'process_data' => 'foo^bar^foo',
      'transaction_number' => 234,
      'signature_counter' => 456,
      'start_time' => DateTime.new(2022, 6, 7, 23, 34, 56),
      'end_time' => DateTime.new(2022, 6, 7, 23, 35, 7),
      'signature' => 'siggy+/sigsig'
    }
  end

  before do
    tickets[0].update(price: 3.21)
    tickets[1].update(price: 2.32)
    purchase.items.new(number: 1, purchasable: tickets[0])
    purchase.items.new(number: 1, purchasable: tickets[1])
    purchase.items.new(number: 2, purchasable: product)
    purchase.items.new(number: 1, purchasable: order_payment)

    allow(purchase).to receive_messages(created_at: DateTime.new(2022, 6, 7, 12, 34, 56), id: 9236)
    # speed up PDF generation by skipping SVG and barcode rendering
    allow(pdf).to receive(:svg_image)
    allow(pdf).to receive(:print_qr_code)
  end

  def spaces(number)
    Prawn::Text::NBSP * number
  end

  include_examples 'it has the correct number of pages', 1

  describe 'ticket items' do
    it 'contains descriptions for ticket items' do
      expect(text_analysis.strings)
        .to include("Ticket #{tickets[0].type.name}", "#{spaces(2)}##{tickets[0].number}",
                    "Ticket #{tickets[1].type.name}", "#{spaces(2)}##{tickets[1].number}")
    end

    it 'contains totals for ticket items' do
      expect(text_analysis.strings).to include('3,21', '2,32')
    end
  end

  describe 'product items' do
    it 'contains descriptions for product items' do
      # for some reason the description gets split up into three strings when using the x character
      expect(text_analysis.strings).to include(product.name, "#{spaces(2)}2 ", '× ', '1,23')
    end

    it 'contains totals for product items' do
      expect(text_analysis.strings).to include('2,46')
    end
  end

  describe 'order payment items' do
    it 'contains descriptions for order payment items' do
      expect(text_analysis.strings).to include('Differenz zu Bestellung', "#{spaces(2)}##{order.number}")
    end

    it 'contains totals for product items' do
      expect(text_analysis.strings).to include('1,11')
    end
  end

  it 'contains the correct total' do
    expect(text_analysis.strings).to include('7,87')
  end

  describe 'VAT rates' do
    it 'contains the correct numbers for the standard VAT rate' do
      expect(text_analysis.strings).to include('A = 19,00 %', '2,07', '0,39', '2,46')
    end

    it 'contains the correct numbers for the reduced VAT rate' do
      expect(text_analysis.strings).to include('B = 7,00 %', '6,21', '0,43', '6,64')
    end

    it 'does not contain any references to the zero VAT rate' do
      expect(text_analysis.strings).not_to include('C = 0,00 %')
    end

    it 'contains the totals for all VAT rates' do
      expect(text_analysis.strings).to include('8,28', '0,82', '9,10')
    end
  end

  describe 'footer' do
    it 'contains the correct date' do
      expect(text_analysis.strings).to include('07.06.2022')
    end

    it 'contains the correct time' do
      expect(text_analysis.strings).to include('12:34:56')
    end

    it 'contains the correct box office id' do
      expect(text_analysis.strings).to include('67')
    end

    it 'contains the correct purchase id' do
      expect(text_analysis.strings).to include('9236')
    end
  end

  describe 'TSE information' do
    it 'draws a QR code with all TSE data' do
      expect(pdf).to receive(:print_qr_code).with(
        'V0;fooby;receipy;foo^bar^foo;234;456;2022-06-07T23:34:56.000Z;2022-06-07T23:35:07.000Z;' \
        "ecdsa-plain-SHA384;unixTime;siggy+/sigsig;#{purchase.tse_device.public_key}",
        anything
      )
      subject
    end

    context 'when tse_info is not present' do
      let(:tse_info) { nil }

      it 'does not draw the QR code' do
        expect(pdf).not_to receive(:print_qr_code)
        subject
      end
    end
  end
end
