# frozen_string_literal: true

FactoryBot.define do
  factory :tse_device, class: 'Ticketing::TseDevice' do
    serial_number { SecureRandom.hex }
    public_key { SecureRandom.hex }
  end
end
