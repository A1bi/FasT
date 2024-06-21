# frozen_string_literal: true

require 'webmock/rspec'

RSpec.describe Ticketing::StripePaymentCreateService do
  subject { service.execute }

  let(:service) { described_class.new(order, payment_method_id) }
  let(:order) { create(:web_order, :complete) }
  let(:amount) { 1.23 }
  let(:payment_method_id) { 'foobar' }
  let(:request_body) do
    {
      amount: '123',
      currency: 'eur',
      confirm: 'true',
      payment_method: payment_method_id
    }
  end
  let(:response_status) { 200 }
  let(:response_body) do
    {
      id: 'stripe_1',
      object: 'payment_intent',
      amount: 456,
      charges: { data: [{ payment_method_details: { card: { wallet: { type: 'apple_pay' } } } }] }
    }
  end
  let!(:request) do
    stub_request(:post, 'https://api.stripe.com/v1/payment_intents')
      .with(body: request_body, basic_auth: ['foobybar'])
      .to_return_json(status: response_status, body: response_body)
  end

  before { order.billing_account.withdraw(amount, :foo) }

  it 'creates a payment intent with Stripe' do
    subject
    expect(request).to have_been_made
  end

  it 'creates a Stripe transaction' do
    expect { subject }.to change(Ticketing::StripeTransaction, :count).by(1)
    transaction = Ticketing::StripeTransaction.last
    expect(transaction.attributes).to include(
      'type' => 'payment_intent',
      'stripe_id' => 'stripe_1',
      'amount' => 4.56,
      'method' => 'apple_pay'
    )
  end

  context 'when Stripe response with an error' do
    let(:response_status) { 400 }

    it 'raises an error' do
      expect { subject }.to raise_error(described_class::TransactionError)
    end
  end

  context 'when order has credit' do
    let(:amount) { -1 }

    it 'raises an error' do
      expect { subject }.to raise_error('Cannot create Stripe payment for order without outstanding balance')
    end
  end
end
