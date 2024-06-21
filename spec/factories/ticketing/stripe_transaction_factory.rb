# frozen_string_literal: true

FactoryBot.define do
  factory :stripe_transaction, class: 'Ticketing::StripeTransaction' do
    order factory: :web_order
    stripe_id { SecureRandom.hex }
    amount { 10 }
    add_attribute(:method) { 'apple_pay' }

    factory :stripe_payment do
      type { 'payment_intent' }
    end
  end
end
