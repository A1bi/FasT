# frozen_string_literal: true

FactoryBot.define do
  factory :ticket, class: 'Ticketing::Ticket' do
    order
    sequence(:order_index) { |n| n }
    association :type, factory: :ticket_type
    date factory: :event_date

    before(:create) do |ticket|
      next unless ticket.event.covid19?

      ticket.covid19_attendee = build(:covid19_attendee)
    end
  end
end
