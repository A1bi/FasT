# frozen_string_literal: true

FactoryBot.define do
  factory :newsletter_subscriber_list, class: 'Newsletter::SubscriberList' do
    name { 'Sample list' }
  end
end
