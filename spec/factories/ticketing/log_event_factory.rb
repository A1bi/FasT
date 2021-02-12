# frozen_string_literal: true

FactoryBot.define do
  factory :log_event, class: 'Ticketing::LogEvent' do
    association :loggable, factory: :coupon
  end
end
