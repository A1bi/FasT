# frozen_string_literal: true

FactoryBot.define do
  factory :covid19_attendee, class: 'Ticketing::Covid19Attendee' do
    name { 'John Doe' }
    street { 'Sample Road' }
    plz { '12345' }
    city { 'Berlin' }
    phone { '030 5550123' }
  end
end
