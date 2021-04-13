# frozen_string_literal: true

RSpec.describe Ticketing::OrderSimulationService do
  subject { service.execute }

  let(:service) { described_class.new(params) }
  let(:params) do
    {
      event_id: event.id,
      tickets: {
        event.ticket_types[0].id => 2,
        event.ticket_types[1].id => 2,
        event.ticket_types[2].id => 0
      },
      coupons: [
        { number: 1, value: 3 }
      ],
      coupon_codes: coupons.pluck(:code)
    }
  end
  let(:create_params) do
    {
      type: :admin,
      order: {
        **params,
        date: event.dates.first.id,
        address: {},
        payment: { method: :transfer }
      }
    }
  end
  let!(:event) do
    create(:event, :complete, :with_free_ticket_type, ticket_types_count: 3)
  end
  let!(:coupons) do
    [create(:coupon, :credit, value: 1),
     create(:coupon, :credit, value: 3),
     create(:coupon, :free_tickets, value: 1),
     create(:coupon, :expired)]
  end
  let(:subtotal) do
    (event.ticket_types[0].price + event.ticket_types[1].price) * 2 + 3
  end

  it 'does not persist or change any records' do
    expect { subject }.to(
      not_change(Ticketing::Order, :count)
      .and(not_change(Ticketing::Ticket, :count))
      .and(not_change(Ticketing::Billing::Account, :count))
      .and(not_change(Ticketing::Billing::Transaction, :count))
      .and(not_change { coupons.pluck(:free_tickets) })
      .and(not_change { coupons.map { |c| c.billing_account.reload.balance } })
      .and(not_change(Ticketing::LogEvent, :count))
    )
  end

  it 'returns the correct amounts' do
    expect(subject[:subtotal]).to eq(subtotal)
    total = subtotal - event.ticket_types[1].price
    expect(subject[:total]).to eq(total)
    total -= 4
    expect(subject[:total_after_coupons]).to eq(total)
    expect(subject[:free_tickets_discount]).to eq(-event.ticket_types[1].price)
    expect(subject[:credit_discount]).to eq(-4)
  end

  it 'matches totals of a real order' do
    order = nil
    ActiveRecord::Base.transaction do
      order = Ticketing::OrderCreateService.new(create_params).execute
      # rollback to make the same coupons usable again
      raise ActiveRecord::Rollback
    end
    expect(subject[:total]).to eq(order.total)
    expect(subject[:total_after_coupons]).to eq(-order.balance)
  end

  it 'returns only valid coupons' do
    expect(subject[:redeemed_coupons]).to eq(coupons[..2])
  end

  context 'when coupon credit exceeds order total' do
    let(:coupons) { [create(:coupon, :credit, value: 1000)] }

    it 'returns the correct amounts' do
      expect(subject[:subtotal]).to eq(subtotal)
      expect(subject[:total]).to eq(subtotal)
      expect(subject[:total_after_coupons]).to eq(0)
      expect(subject[:free_tickets_discount]).to eq(0)
      expect(subject[:credit_discount]).to eq(-subtotal)
    end
  end

  context 'when free tickets exceed number of tickets' do
    let(:coupons) { [create(:coupon, :free_tickets, value: 10)] }

    it 'returns the correct amounts' do
      expect(subject[:subtotal]).to eq(subtotal)
      expect(subject[:total]).to eq(3)
      expect(subject[:total_after_coupons]).to eq(3)
      expect(subject[:free_tickets_discount]).to eq(-(subtotal - 3))
      expect(subject[:credit_discount]).to eq(0)
    end
  end

  context 'without coupons to redeem' do
    let(:coupons) { [] }

    it 'returns the correct totals' do
      total = (event.ticket_types[0].price + event.ticket_types[1].price) * 2 +
              3
      expect(subject[:subtotal]).to eq(total)
      expect(subject[:total]).to eq(total)
      expect(subject[:total_after_coupons]).to eq(total)
      expect(subject[:free_tickets_discount]).to eq(0)
      expect(subject[:credit_discount]).to eq(0)
    end
  end
end
