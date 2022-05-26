# frozen_string_literal: true

FactoryBot.define do
  factory :vat_rate, class: 'Ticketing::VatRate' do
    rate { 19 }
  end
end
