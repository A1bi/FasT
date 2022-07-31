# frozen_string_literal: true

FactoryBot.define do
  factory :web_order, class: 'Ticketing::Web::Order', parent: :order do
    email { 'foo@example.com' }
    gender { 0 }
    first_name { 'John' }
    last_name { 'Doe' }
    affiliation { 'Foobar Inc' }
    plz { '13403' }
    phone { '0305550123' }

    trait :transfer_payment do
      pay_method { :transfer }
    end

    trait :charge_payment do
      pay_method { :charge }
      bank_charge
    end

    trait :anonymized do
      after(:create, &:anonymize!)
    end
  end
end
