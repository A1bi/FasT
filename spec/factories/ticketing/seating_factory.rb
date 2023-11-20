# frozen_string_literal: true

FactoryBot.define do
  factory :seating, class: 'Ticketing::Seating' do
    name { 'Seating' }
    plan_file_name { 'foo.svg' }
  end
end
