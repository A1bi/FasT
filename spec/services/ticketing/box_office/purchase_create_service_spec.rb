# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::PurchaseCreateService do
  subject { service.execute }

  let(:service) { described_class.new(params, box_office) }
  let(:box_office) { create(:box_office) }
  let(:product) { create(:box_office_product) }
  let(:order) { create(:web_order, :with_tickets, :unpaid, tickets_count: 1) }
  let(:ticket) { order.tickets.first }
  let(:params) do
    {
      pay_method: :electronic_cash,
      items: [
        {
          type: 'product',
          id: product.id,
          number: 1
        },
        {
          type: 'ticket',
          id: ticket.id
        }
      ]
    }
  end

  it 'creates a purchase' do
    expect { subject }.to change(Ticketing::BoxOffice::Purchase, :count).by(1)
  end

  it 'creates three purchase items' do
    expect { subject }.to change(Ticketing::BoxOffice::PurchaseItem, :count).by(2)
  end

  it 'marks the order as paid' do
    expect { subject }.to change { order.reload.paid }.to(true)
  end

  context 'when ticket is cancelled' do
    before { ticket.update(cancellation: create(:cancellation)) }

    it 'raises an error' do
      expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it 'broadcasts to front displays' do
    expect { subject }.to(
      have_broadcasted_to(box_office).from_channel(Ticketing::BoxOffice::FrontDisplayChannel).with do |params|
        purchase = Ticketing::BoxOffice::Purchase.last
        expect(params[:id]).to eq(purchase.id)
        expect(params[:token]).to eq(purchase.receipt_token)
      end
    )
  end

  context 'with TSE enabled' do
    before { Settings.tse.enabled = true }

    it 'enqueues a TSE transaction job' do
      expect { subject }.to(have_enqueued_job(Ticketing::BoxOffice::TseTransactionJob).with do |params|
        expect(params[:purchase]).to eq(Ticketing::BoxOffice::Purchase.last)
      end)
    end
  end

  context 'with TSE disabled' do
    before { Settings.tse.enabled = false }

    it 'does not enqueue a TSE transaction job' do
      expect { subject }.not_to have_enqueued_job(Ticketing::BoxOffice::TseTransactionJob)
    end
  end
end
