# frozen_string_literal: true

FactoryBot.define do
  factory :check_in, class: 'Ticketing::CheckIn' do
    ticket
    medium { 'web' }
    date { Time.current }
  end
end
