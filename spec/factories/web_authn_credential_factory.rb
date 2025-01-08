# frozen_string_literal: true

FactoryBot.define do
  factory :web_authn_credential do
    id { SecureRandom.hex }
    user
    public_key { SecureRandom.hex }
    aaguid { 'd548826e-79b4-db40-a3d8-11116f7e8349' }
  end
end
