# frozen_string_literal: true

RSpec.describe 'Ticketing::BoxOffice::PurchasesController' do
  let(:purchase) { create(:box_office_purchase, :with_items).reload }
  let(:token) { purchase.receipt_token.remove('-') }
  let(:pdf) { instance_double(Ticketing::BoxOffice::PurchaseReceiptPdf) }

  before do
    allow(Ticketing::BoxOffice::PurchaseReceiptPdf).to receive(:new).and_return(pdf)
    allow(pdf).to receive(:purchase=)
    allow(pdf).to receive(:render).and_return('foopdf')
  end

  describe 'GET #show' do
    subject { get "#{ticketing_box_office_purchase_path(token)}.pdf" }

    context 'with a valid token' do
      it 'uses the correct purchase to generate a PDF' do
        expect(pdf).to receive(:purchase=).with(purchase)
        subject
      end

      it 'returns the rendered PDF' do
        subject
        expect(response.body).to eq('foopdf')
      end
    end

    context 'with an invalid token' do
      let(:token) { 'foo' }

      it 'raises an exception which results in a 404' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
