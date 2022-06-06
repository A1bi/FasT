# frozen_string_literal: true

FactoryBot.define do
  factory :box_office_order_payment, class: 'Ticketing::BoxOffice::OrderPayment' do
    order
    amount { rand(1.0..20.0) }
  end
end
