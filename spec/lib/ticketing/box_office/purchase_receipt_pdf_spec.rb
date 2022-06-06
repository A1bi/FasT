# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.describe Ticketing::BoxOffice::PurchaseReceiptPdf do
  let(:order) { create(:order, :with_tickets, tickets_count: 2) }
  let(:tickets) { order.tickets }
  let(:purchase) { build(:box_office_purchase, total: 7.87) }
  let(:product) { create(:box_office_product, price: 1.23, vat_rate: :standard) }
  let(:order_payment) { create(:box_office_order_payment, order:, amount: 1.11) }
  let(:pdf) { described_class.new(purchase).render }
  let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }
  let(:page_analysis) { PDF::Inspector::Page.analyze(pdf) }

  before do
    tickets[0].update(price: 3.21)
    tickets[1].update(price: 2.32)
    purchase.items.new(number: 1, purchasable: tickets[0])
    purchase.items.new(number: 1, purchasable: tickets[1])
    purchase.items.new(number: 2, purchasable: product)
    purchase.items.new(number: 1, purchasable: order_payment)
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
      expect(text_analysis.strings).to include(product.name, "#{spaces(2)}2 x 1,23")
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
end
