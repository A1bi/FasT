# frozen_string_literal: true

require_shared_examples 'pdf'

RSpec.describe Ticketing::BoxOffice::PurchaseReceiptPdf do
  let(:order) { create(:order, :with_tickets, tickets_count: 2) }
  let(:tickets) { order.tickets }
  let(:purchase) { build(:box_office_purchase) }
  let(:product) { create(:box_office_product, price: 1.23) }
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
end
