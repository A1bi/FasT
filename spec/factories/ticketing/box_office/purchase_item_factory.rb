# frozen_string_literal: true

FactoryBot.define do
  factory :box_office_purchase_item, class: 'Ticketing::BoxOffice::PurchaseItem' do
    number { rand(1..4) }
    purchasable factory: :box_office_product
  end
end
