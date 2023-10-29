# frozen_string_literal: true

FactoryBot.define do
  factory :membership_application, class: 'Members::MembershipApplication' do
    first_name { 'John' }
    last_name { 'Doe' }
    gender { :female }
    street { 'Sample road' }
    plz { '12345' }
    city { 'Berlin' }
    sequence(:email) { |n| "member#{n}@example.com" }
    birthday { '2023-10-29' }
    debtor_name { 'John Doe' }
    iban { 'DE89370400440532013000' }
  end
end
