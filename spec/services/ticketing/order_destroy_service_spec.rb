# frozen_string_literal: true

RSpec.describe Ticketing::OrderDestroyService do
  subject { service.execute }

  let(:service) { described_class.new(order) }
  let(:order) { create(:order, :with_tickets) }
  let(:tickets) { order.tickets.to_a }

  it 'destroys the order' do
    expect { subject }.to change(order, :destroyed?).to(true)
  end

  it 'updates node seats' do
    expect(NodeApi).to receive(:update_seats_from_records).with(tickets)
    subject
  end
end
