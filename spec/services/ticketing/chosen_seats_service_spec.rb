# frozen_string_literal: true

RSpec.describe Ticketing::ChosenSeatsService do
  let(:service) { described_class.new(socket_id) }
  let(:socket_id) { 'foo_bar' }
  let(:seating) { create(:seating, :with_seats, seat_count: 3) }
  let(:seats) { seating.seats }
  let(:chosen_seats) { [seats[1], seats[0], seats[2]].pluck(:id) }

  before do
    seats[0].update(number: 5)
    seats[1].update(number: 6)
    seats[2].update(number: 4)
    allow(NodeApi).to receive(:get_chosen_seats).with(socket_id).and_return(chosen_seats)
    allow(Sentry::Breadcrumb).to receive(:new).and_call_original
  end

  describe '#seats' do
    subject { service.seats }

    it 'returns the correct seats ordered by number' do
      expect(subject).to eq([seats[2], seats[0], seats[1]])
    end

    context 'with a correct socket id' do
      it 'creates a successful Sentry breadcrumb' do
        expect(Sentry::Breadcrumb).to receive(:new).with(message: 'Received chosen seats from node', type: 'debug',
                                                         data: { seats: chosen_seats })
        subject
      end
    end

    context 'with an incorrect socket id' do
      let(:chosen_seats) { nil }

      it 'creates an unsuccessful Sentry breadcrumb' do
        expect(Sentry::Breadcrumb).to receive(:new).with(message: 'Unknown socket id', type: 'error', level: 'error')
        subject
      end
    end
  end

  describe '#next' do
    it 'returns and removes the next seat until no more seats are available' do
      expect(service.next).to eq(seats[2])
      expect(service.next).to eq(seats[0])
      expect(service.next).to eq(seats[1])
      expect(service.next).to be_nil
    end
  end
end
