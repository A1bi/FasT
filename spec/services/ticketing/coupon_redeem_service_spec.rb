# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::CouponRedeemService do
  subject do
    service.execute(**execution_params)
    order.save
  end

  let(:service) { described_class.new(order, date, nil, params) }
  let(:order) { build(:web_order) }
  let(:event) { create(:event, :complete) }
  let(:date) { event.dates.first }
  let(:codes) { [*coupons.pluck(:code), 'foooo'] }
  let(:params) { { coupon_codes: codes } }
  let(:execution_params) { { free_tickets: true, credit: true } }

  context 'with a free tickets coupon' do
    let!(:tickets) do
      type = create(:ticket_type, event:, price: 1000)
      type2 = create(:ticket_type, event:, price: 999)
      event.ticket_types += [type, type2]

      ticket = build(:ticket, order:, date:, type:)
      ticket2 = build(:ticket, order:, date:, type: type2)

      # mix expensive tickets with cheaper tickets
      order.tickets = [
        build(:ticket, order:, date:, type: event.ticket_types.first),
        ticket,
        build(:ticket, order:, date:, type: event.ticket_types.first),
        ticket2,
        build(:ticket, order:, date:, type: event.ticket_types.first)
      ]

      [ticket, ticket2]
    end
    let(:coupons) do
      [
        create(:coupon, :expired),
        create(:coupon, :free_tickets, value: 2)
      ]
    end

    context 'when free ticket type does not exist' do
      it {
        expect { subject }.to raise_error(Ticketing::CouponRedeemService::FreeTicketTypeMissingError)
      }
    end

    context 'when free ticket type exists' do
      let!(:free_ticket_type) do
        type = create(:ticket_type, :free, event:)
        event.ticket_types << type
        type
      end

      it 'redeems only the valid coupon' do
        subject
        expect(order.redeemed_coupons).to contain_exactly(coupons.second)
      end

      context 'when free tickets should be used' do
        it 'changes the ticket type to free, tickets w/ highest price first' do
          expect { subject }.to change { tickets.map(&:type).uniq }.to([free_ticket_type])
        end

        it 'decreases the remaining free tickets' do
          expect { subject }.to change { coupons.last.reload.free_tickets }.to(0)
        end

        it 'creates a transaction for the redeemed free tickets' do
          expect { subject }.to change(coupons.last.billing_account.transactions, :count).by(1)
          transaction = coupons.last.billing_account.transactions.last
          expect(transaction.amount).to eq(-2)
          expect(transaction.note_key).to eq('redeemed_coupon')
        end

        context 'when more free tickets than ordered tickets are available' do
          let(:tickets) do
            order.tickets = [build(:ticket, order:, date:, type: event.ticket_types.first)]
          end

          it 'decreases the remaining free tickets' do
            expect { subject }.to change { coupons.last.reload.free_tickets }.to(1)
          end
        end

        context 'when multiple valid coupons are provided' do
          # there are 5 tickets in the order and 4 free tickets in coupons
          let(:coupons) { create_list(:coupon, 2, :free_tickets, value: 2) }

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

      it_behaves_like 'creates a log event', :redeemed do
        let(:loggable) { coupons.last }
      end

      it_behaves_like 'does not create a log event' do
        let(:loggable) { coupons.first }
      end

      shared_examples 'does not redeem free tickets' do
        it 'does not change any ticket type' do
          expect { subject }.not_to(change { order.tickets.map(&:type) })
        end

        it 'does not decrease the remaining free tickets' do
          expect { subject }.not_to(change { coupons.last.reload.free_tickets })
        end
      end

      context 'when free tickets coupon redemption is not desired' do
        let(:execution_params) { { free_tickets: false } }

        it_behaves_like 'does not redeem free tickets'
      end
    end
  end

  context 'with a credit coupon' do
    let(:coupons) do
      [
        create(:coupon, :credit, :expired),
        create(:coupon, :credit, value: 25)
      ]
    end

    before { order.billing_account.balance = -33 }

    it 'adds the coupon credit to the order account' do
      expect { subject }.to change(order.billing_account, :balance).from(-33).to(-8)
    end

    it 'updates the coupon credit' do
      expect { subject }.to change { coupons.last.reload.value }.from(25).to(0)
    end

    it_behaves_like 'creates a log event', :redeemed do
      let(:loggable) { coupons.last }
    end

    it_behaves_like 'does not create a log event' do
      let(:loggable) { coupons.first }
    end

    context 'with multiple credit coupons with lower value than order' do
      let(:coupons) do
        [
          create(:coupon, :credit, value: 25),
          create(:coupon, :credit, value: 10)
        ]
      end

      it 'adds the coupon credit to the order account' do
        expect { subject }.to change(order.billing_account, :balance).from(-33).to(0)
      end

      it 'updates the coupon credit' do
        expect { subject }.to(
          change { coupons[0].reload.value }.from(25).to(0)
          .and(change { coupons[1].reload.value }.from(10).to(2))
        )
      end
    end

    context 'when credit coupon redemption is not desired' do
      let(:execution_params) { { credit: false } }

      it 'does not change the order balance' do
        expect { subject }.not_to change(order.billing_account, :balance)
      end

      it 'does not change the coupon balance' do
        expect { subject }.not_to(change { coupons[1].reload.value })
      end
    end
  end

  context 'with same coupon multiple times' do
    let(:codes) { [coupon.code] * 2 }
    let(:coupon) { create(:coupon, :credit, value: 5) }

    before { order.billing_account.balance = -20 }

    it 'transfers coupon credit only once' do
      expect { subject }.to change(order.billing_account, :balance).to(-15)
    end

    it 'creates redemption only once' do
      subject
      expect(order.redeemed_coupons).to contain_exactly(coupon)
    end
  end

  shared_examples 'mixed redemption' do
    let(:coupons) do
      [
        create(:coupon, :free_tickets, value: 2),
        create(:coupon, :credit, value: 15)
      ]
    end

    before do
      type = create(:ticket_type, event:, price: 10)
      type2 = create(:ticket_type, event:, price: 20)
      type3 = create(:ticket_type, :free, event:)
      event.ticket_types += [type, type2, type3]

      order.tickets += build_list(:ticket, 2, order:, date:, type:)
      order.tickets += build_list(:ticket, 2, order:, date:, type: type2)

      order.billing_account.balance = -20
    end

    it 'redeems free tickets and transfers credit' do
      subject
      expect(order.tickets[..1].map(&:price)).to eq([10, 10])
      expect(order.tickets[2..].map(&:price)).to eq([0, 0])
      expect(order.billing_account.balance).to eq(-5)
    end

    it 'creates a redemption once for each coupon' do
      subject
      expect(order.redeemed_coupons).to match_array(coupons)
    end
  end

  context 'with coupons with mixed value types' do
    it_behaves_like 'mixed redemption'
  end

  context 'when executed multiple times with different params' do
    subject do
      service.execute(credit: false)
      service.execute(free_tickets: false)
      order.save
    end

    it_behaves_like 'mixed redemption'
  end

  context 'with a coupon already added to this order previously' do
    let(:coupons) { create_list(:coupon, 1, :credit, value: 15) }

    before do
      order.billing_account.balance = -20
      order.redeemed_coupons << coupons.first
    end

    it 'does not redeem the coupon again' do
      expect { subject }.to(
        not_change(order.billing_account, :balance)
        .and(not_change(order.redeemed_coupons, :size))
      )
    end
  end
end
