# frozen_string_literal: true

FactoryBot.define do
  factory :log_event, class: 'Ticketing::LogEvent' do
    loggable factory: :coupon
  end
end
