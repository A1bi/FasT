# frozen_string_literal: true

require 'support/api_requests'
require 'support/authentication'

RSpec.describe 'Api::Ticketing::OrdersController' do
  describe 'GET #totals' do
    subject do
      post_json totals_api_ticketing_orders_path, params: params
    end

    let(:params) do
      {
        'event_id' => event.id,
        'order' => {
          'ignore_free_tickets' => false,
          'tickets' => {
            event.ticket_types.first.id.to_s => 2
          },
          'coupons' => [
            { 'value' => 11, 'number' => 2 }
          ],
          'coupon_codes' => coupons.pluck(:code)
        }
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
        expect(json_response['total']).to eq(total)
        expect(json_response['total_before_coupons']).to eq(total)
        expect(json_response['total_after_coupons']).to eq(total)
      end
    end

    shared_examples 'no redeemed coupons' do
      it 'renders no redeemed coupons' do
        subject
        expect(json_response['redeemed_coupons']).to eq([])
      end
    end

    it 'populates an empty order' do
      service_params = {
        'order' => {
          **params['order'],
          'date' => event.dates.first.id
        }
      }
      expect(Ticketing::OrderPopulateService)
        .to(receive(:new).with(anything, service_params, current_user: user)
                         .and_call_original)
      subject
    end

    context 'without coupons to redeem' do
      include_examples 'renders totals'
      include_examples 'no redeemed coupons'
    end

    context 'with coupons to redeem' do
      let(:coupons) do
        [
          create(:coupon, free_tickets: 1),
          create(:coupon, :with_credit, value: 13)
        ]
      end

      it 'renders totals' do
        subject
        total = event.ticket_types.first.price + 22
        expect(json_response['total']).to eq(total)
        expect(json_response['total_before_coupons'])
          .to eq(total + event.ticket_types.first.price)
        expect(json_response['total_after_coupons']).to eq(total - 13)
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
