# frozen_string_literal: true

RSpec.describe Ticketing::TicketTransferService do
  subject { service.execute }

  let(:service) do
    described_class.new(tickets, new_date_id: new_date.id, order_id: order.id, socket_id: nil,
                                 current_user: nil, by_customer:)
  end
  let(:event) { create(:event, :complete, dates_count: 2) }
  let(:order) { create(:order, :with_tickets, event:, date: old_date, tickets_count: 2) }
  let(:tickets) { order.tickets }
  let(:old_date) { event.dates.first }
  let(:new_date) { event.dates.last }
  let(:by_customer) { false }

  shared_examples 'changes dates' do
    it 'changes the dates' do
      expect { subject }.to change { tickets.reload.pluck(:date_id) }.from([old_date.id] * 2).to([new_date.id] * 2)
    end
  end

  include_examples 'changes dates'

  context 'when not enough seats are available' do
    before { event.update(number_of_seats: 1) }

    include_examples 'changes dates'

    context 'when in customer mode' do
      let(:by_customer) { true }

      it 'does not change the dates' do
        expect { subject }.not_to(change { tickets.reload.pluck(:date_id) })
      end
    end
  end
end
