# frozen_string_literal: true

FactoryBot.define do
  factory :box_office_product, class: 'Ticketing::BoxOffice::Product' do
    name { FFaker::Product.product_name }
    price { rand(5.0..20.0) }
    vat_rate { %i[standard reduced zero].sample }
  end
end
