# frozen_string_literal: true

FactoryBot.define do
  factory :box_office_purchase, class: 'Ticketing::BoxOffice::Purchase' do
    box_office

    trait :with_items do
      before(:create) do |purchase|
        purchase.items = create_list(:box_office_purchase_item, 2, purchase:)
      end
    end
  end
end
