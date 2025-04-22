# frozen_string_literal: true

RSpec.describe Ticketing::OrderSearchService do
  subject { service.execute }

  let(:service) { described_class.new(query.to_s) }
  let(:order) { create(:web_order, :with_tickets, tickets_count: 2, last_name: 'Mercury', plz: '12345') }

  before do
    create_list(:web_order, 2, :complete)
  end

  shared_examples 'finds order' do
    it { is_expected.to eq([[order], nil]) }
  end

  context 'with an order number query' do
    let(:query) { order.number }

    it_behaves_like 'finds order'
  end

  context 'with a ticket number query' do
    let(:query) { order.tickets.last.number }

    it { is_expected.to eq([[order], order.tickets.last]) }
  end

  context 'with a postcode query' do
    let(:query) { '12345' }

    it_behaves_like 'finds order'
  end

  context 'with a text query' do
    let(:query) { 'Freddie Mercury' }

    it_behaves_like 'finds order'
  end

  context 'when query does not match anything' do
    let(:query) { 'Rhapsody' }

    it { is_expected.to eq([[], nil]) }
  end
end
