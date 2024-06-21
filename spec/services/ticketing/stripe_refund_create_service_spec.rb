# frozen_string_literal: true

require 'webmock/rspec'

RSpec.describe Ticketing::StripeRefundCreateService do
  subject { service.execute }

  let(:service) { described_class.new(order) }
  let(:order) { create(:web_order, :complete) }
  let(:amount) { 12 }
  let(:payment) { create(:stripe_payment, order:) }
  let(:request_body) do
    {
      amount: '1200',
      payment_intent: payment.id.to_s
    }
  end
  let(:response_status) { 200 }
  let(:response_body) do
    {
      id: 'stripe_1',
      object: 'refund',
      amount: '1200'
    }
  end
  let!(:request) do
    stub_request(:post, 'https://api.stripe.com/v1/refunds')
      .with(body: request_body, basic_auth: ['foobybar'])
      .to_return_json(status: response_status, body: response_body)
  end

  before { order.billing_account.deposit(amount, :foo) }

  it 'creates a refund with Stripe' do
    subject
    expect(request).to have_been_made
  end

  it 'creates a Stripe transaction' do
    expect { subject }.to change(order.stripe_transactions, :count).by(1)
    transaction = order.stripe_transactions.last
    expect(transaction.attributes).to include(
      'type' => 'refund',
      'stripe_id' => 'stripe_1',
      'amount' => amount
    )
  end

  context 'when Stripe response with an error' do
    let(:response_status) { 400 }

    it 'raises an error' do
      expect { subject }.to raise_error(described_class::TransactionError)
    end
  end

  context 'when order has outstanding balance' do
    let(:amount) { -10 }

    it 'raises an error' do
      expect { subject }.to raise_error('Cannot create Stripe refund for order without credit')
    end
  end
end
