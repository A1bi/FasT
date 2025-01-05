# frozen_string_literal: true

class WebAuthnCredential < ApplicationRecord
  CREDENTIAL_PROVIDERS_URL = 'https://github.com/passkeydeveloper/passkey-authenticator-aaguids/raw/refs/heads/main/combined_aaguid.json'

  belongs_to :user

  validates :public_key, presence: true

  class << self
    def providers
      @providers ||= Rails.cache.fetch(%i[web_authn credential_providers], expires_in: 1.month) do
        res = URI.parse(CREDENTIAL_PROVIDERS_URL).open
        JSON.parse(res.read)
      end
    end
  end

  def provider_known?
    aaguid.present? && self.class.providers.key?(aaguid)
  end

  def provider_name
    provider_attribute('name')
  end

  def provider_icon_light
    provider_attribute('icon_light')
  end

  def provider_icon_dark
    provider_attribute('icon_dark')
  end

  private

  def provider_attribute(attr)
    self.class.providers.dig(aaguid, attr)
  end
end
