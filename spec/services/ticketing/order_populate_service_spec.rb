# frozen_string_literal: true

RSpec.describe Ticketing::OrderPopulateService do
  subject { service.execute }

  let(:service) { described_class.new(order, params) }
  let(:order) { Ticketing::Order.new }
  let(:params) do
    {
      order: {
        date: event.dates.first.id,
        tickets: {
          event.ticket_types[0].id => 2,
          event.ticket_types[1].id => 2
        },
        coupons: [
          { number: 1, value: 3 }
        ],
        coupon_codes: coupons.pluck(:code)
      }
    }
  end
  let(:event) { create(:event, :complete, ticket_types_count: 2) }
  let!(:coupons) do
    [create(:coupon, :with_credit, value: 1),
     create(:coupon, :with_free_tickets, free_tickets: 1)]
  end
  let!(:free_ticket_type) { create(:ticket_type, :free, event: event) }

  it 'does not persist any records' do
    expect { subject }.to(
      not_change(Ticketing::Order, :count)
      .and(not_change(Ticketing::Ticket, :count))
      .and(not_change(Ticketing::Billing::Account, :count))
      .and(not_change(Ticketing::Billing::Transaction, :count))
    )
  end

  it 'adds tickets' do
    subject
    expect(order.tickets.size).to eq(4)
    expect(order.tickets[0].type).to eq(event.ticket_types[0])
    expect(order.tickets[1].type).to eq(event.ticket_types[0])
    expect(order.tickets[2].type).to eq(event.ticket_types[1])
    expect(order.tickets[3].type).to eq(free_ticket_type)
  end

  it 'adds coupons' do
    subject
    expect(order.purchased_coupons.size).to eq(1)
    expect(order.purchased_coupons[0].billing_account.balance).to eq(3)
  end

  it 'redeems credit coupons' do
    subject
    total = event.ticket_types[0].price * 2 + event.ticket_types[1].price + 3
    expect(order.total).to eq(total)
    expect(order.billing_account.balance).to eq(-total + coupons.first.value)
  end

  it 'sets total_before_coupons' do
    total = (event.ticket_types[0].price + event.ticket_types[1].price) * 2 + 3
    expect { subject }.to change(order, :total_before_coupons).to(total)
    expect(order.total_before_coupons).to be > order.total
  end

  context 'with a retail order' do
    let(:order) { Ticketing::Retail::Order.new }
    let(:store) { create(:retail_store) }

    before { order.store = store }

    it 'withdraws from the retail billing account' do
      subject
      expect(order.billing_account.balance).to eq(0)
      expect(store.billing_account.balance).to eq(-order.total)
    end
  end
end
