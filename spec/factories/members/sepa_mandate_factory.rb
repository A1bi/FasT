# frozen_string_literal: true

FactoryBot.define do
  factory :members_sepa_mandate, class: 'Members::SepaMandate' do
    debtor_name { FFaker::NameDE.name }
    iban { 'DE89370400440532013000' }
  end
end
