# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::CouponRedeemService do
  subject do
    service.execute
    order.save
  end

  let(:service) { described_class.new(order, date, nil, params) }
  let(:order) { build(:web_order) }
  let(:event) { create(:event, :complete) }
  let(:date) { event.dates.first }
  let(:codes) { [*coupons.pluck(:code), 'foooo'] }
  let(:ignore_free_tickets) { false }
  let!(:tickets) do
    type = create(:ticket_type, event: event, price: 1000)
    type2 = create(:ticket_type, event: event, price: 999)
    event.ticket_types += [type, type2]

    ticket = build(:ticket, order: order, date: date, type: type)
    ticket2 = build(:ticket, order: order, date: date, type: type2)

    # mix expensive tickets with cheaper tickets
    order.tickets = [
      build(:ticket, order: order, date: date, type: event.ticket_types.first),
      ticket,
      build(:ticket, order: order, date: date, type: event.ticket_types.first),
      ticket2,
      build(:ticket, order: order, date: date, type: event.ticket_types.first)
    ]

    [ticket, ticket2]
  end
  let(:coupons) do
    [
      create(:coupon, :expired, free_tickets: 2),
      create(:coupon, free_tickets: 2)
    ]
  end
  let(:params) do
    { ignore_free_tickets: ignore_free_tickets, coupon_codes: codes }
  end

  context 'when free ticket type does not exist' do
    it {
      expect { subject }.to raise_error(Ticketing::CouponRedeemService::
                                        FreeTicketTypeMissingError)
    }
  end

  context 'when free ticket type exists' do
    let!(:free_ticket_type) do
      type = create(:ticket_type, :free, event: event)
      event.ticket_types << type
      type
    end

    it 'redeems only the valid coupon' do
      subject
      expect(order.redeemed_coupons).to contain_exactly(coupons.second)
    end

    context 'when free tickets should be used' do
      it 'changes the ticket type to free, tickets with highest price first' do
        expect { subject }
          .to change { tickets.map(&:type).uniq }.to([free_ticket_type])
      end

      it 'decreases the remaining free tickets' do
        expect { subject }.to change { coupons.last.reload.free_tickets }.to(0)
      end

      context 'when more free tickets than ordered tickets are available' do
        let(:tickets) do
          order.tickets = [build(:ticket, order: order, date: date,
                                          type: event.ticket_types.first)]
        end

        it 'decreases the remaining free tickets' do
          expect { subject }
            .to change { coupons.last.reload.free_tickets }.to(1)
        end
      end

      context 'when multiple valid coupons are provided' do
        # there are 5 tickets in the order and 4 free tickets in coupons
        let(:coupons) { create_list(:coupon, 2, free_tickets: 2) }

        it 'sets the remaining free tickets correctly' do
          expect { subject }.to(
            change { coupons[0].reload.free_tickets }.to(0)
            .and(change { coupons[1].reload.free_tickets }.to(0))
          )
        end

        it 'changes the ticket type of only four tickets' do
          expect { subject }.not_to change(order.tickets.first, :type)
          expect(order.tickets[1..].map(&:type)).to all(eq(free_ticket_type))
        end
      end
    end

    context 'when free tickets should be ignored' do
      let(:ignore_free_tickets) { true }

      it 'does not change any ticket type' do
        expect { subject }.not_to(change { order.tickets.map(&:type) })
      end

      it 'does not decrease the remaining free tickets' do
        expect { subject }.not_to(change { coupons.last.reload.free_tickets })
      end
    end

    it_behaves_like 'creates a log event', :redeemed do
      let(:loggable) { coupons.last }
    end

    it_behaves_like 'does not create a log event' do
      let(:loggable) { coupons.first }
    end
  end
end
