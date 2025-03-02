# frozen_string_literal: true

WebAuthn.configure do |config|
  config.allowed_origins = [
    URI::Generic.build(**Settings.url_options.to_h, scheme: Settings.url_options[:protocol]).to_s
  ]
  config.rp_name = 'TheaterKultur Kaisersesch'
  config.verify_attestation_statement = false
end
