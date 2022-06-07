# frozen_string_literal: true

FactoryBot.define do
  factory :box_office_purchase, class: 'Ticketing::BoxOffice::Purchase' do
    box_office

    trait :with_items do
      transient do
        items_count { 2 }
      end

      before(:create) do |purchase, evaluator|
        purchase.items = create_list(:box_office_purchase_item, evaluator.items_count, purchase:)
      end
    end

    trait :with_tse_device do
      tse_device
    end
  end
end
