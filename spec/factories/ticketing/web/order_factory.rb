# frozen_string_literal: true

FactoryBot.define do
  factory :web_order, class: Ticketing::Web::Order, parent: :order
end
