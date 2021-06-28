# frozen_string_literal: true

require 'support/api_requests'
require 'support/authentication'

RSpec.describe 'Api::Ticketing::OrdersController' do
  describe 'POST #totals' do
    subject { post_json totals_api_ticketing_orders_path, params: params }

    let(:params) do
      {
        event_id: event.id,
        tickets: {
          event.ticket_types.first.id => 2
        },
        coupons: [
          { value: 11, number: 2 }
        ],
        coupon_codes: coupons.pluck(:code)
      }
    end
    let(:event) { create(:event, :complete, :with_free_ticket_type) }
    let(:coupons) { [] }
    let(:user) { build(:user) }

    before { sign_in(user: user) }

    shared_examples 'renders totals' do
      it 'renders totals' do
        subject
        total = event.ticket_types.first.price * 2 + 22
        expect(json_response['subtotal']).to eq(total)
        expect(json_response['total']).to eq(total)
        expect(json_response['total_after_coupons']).to eq(total)
        expect(json_response['free_tickets_discount']).to eq(0)
        expect(json_response['credit_discount']).to eq(0)
      end
    end

    shared_examples 'no redeemed coupons' do
      it 'renders no redeemed coupons' do
        subject
        expect(json_response['redeemed_coupons']).to eq([])
      end
    end

    context 'without coupons to redeem' do
      include_examples 'renders totals'
      include_examples 'no redeemed coupons'
    end

    context 'with coupons to redeem' do
      let(:coupons) do
        [
          create(:coupon, :free_tickets, value: 1),
          create(:coupon, :credit, value: 13)
        ]
      end

      it 'renders totals' do
        subject
        first_price = event.ticket_types.first.price
        total = first_price + 22
        expect(json_response['total']).to eq(total)
        expect(json_response['subtotal']).to eq(total + first_price)
        expect(json_response['total_after_coupons']).to eq(total - 13)
        expect(json_response['free_tickets_discount']).to eq(-first_price)
        expect(json_response['credit_discount']).to eq(-13)
      end

      it 'renders redeemed coupons' do
        subject
        expect(json_response['redeemed_coupons']).to eq(coupons.pluck(:code))
      end
    end

    context 'with an invalid coupon to redeem' do
      let(:coupons) { [create(:coupon, :expired)] }

      include_examples 'no redeemed coupons'
    end

    context 'with an event with seating plan' do
      let(:event) { create(:event, :complete, :with_seating_plan) }

      include_examples 'renders totals'
    end
  end
end
