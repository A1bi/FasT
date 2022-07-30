# frozen_string_literal: true

FactoryBot.define do
  factory :bank_charge, class: 'Ticketing::BankCharge' do
    name { 'John Doe' }
    iban { 'DE75512108001245126199' }
    association :order, factory: %i[web_order with_purchased_coupons]
  end
end
