# frozen_string_literal: true

RSpec.describe Ticketing::TicketCreateService do
  subject { service.execute }

  let(:service) { described_class.new(order, date, nil, params) }
  let(:order) { build(:web_order) }
  let(:event) { create(:event, :with_dates, :with_ticket_types, ticket_types_count: 2, seating:) }
  let(:date) { event.dates.first }
  let(:types) { event.ticket_types.order(price: :asc) }
  let(:seating) { create(:seating, :with_seats, seat_count: 3) }
  let(:seats) { seating.seats }
  let(:order_type) { :web }
  let(:socket_id) { 'fooby' }
  let(:chosen_seats) { [seats[1], seats[0], seats[2]].pluck(:id) }
  let(:params) do
    {
      order: {
        tickets: {
          types[0].id => 2,
          types[1].id => 1
        }
      },
      socket_id:,
      type: order_type
    }
  end

  before do
    allow(NodeApi).to receive(:get_chosen_seats).with(socket_id).and_return(chosen_seats)
  end

  it 'builds the correct number of tickets' do
    expect { subject }.to change(order.tickets, :size).to(3)
  end

  it 'uses the correct ticket types' do
    subject
    expect(order.tickets.map(&:type)).to eq([types[0], types[0], types[1]])
  end

  it 'uses the correct seats ordered by number' do
    subject
    expect(order.tickets.map(&:seat)).to eq(seats)
  end

  context 'when not enough seats are available' do
    before { allow(date).to receive(:number_of_available_seats).and_return(2) }

    it 'creates no tickets' do
      subject
      expect(order.tickets).to be_empty
    end

    it 'adds an error to the order' do
      subject
      expect(order.errors).to be_added(:tickets, 'Not enough seats available')
    end

    context 'when in admin mode' do
      let(:order_type) { :admin }

      it 'creates tickets' do
        subject
        expect(order.tickets).not_to be_empty
      end
    end
  end
end
