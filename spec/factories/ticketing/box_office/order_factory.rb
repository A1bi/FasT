# frozen_string_literal: true

FactoryBot.define do
  factory :box_office_order, class: 'Ticketing::BoxOffice::Order',
                             parent: :order do
    box_office
  end
end
