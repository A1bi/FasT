# frozen_string_literal: true

WebAuthn.configure do |config|
  config.origin = URI::HTTP.build(Settings.url_options.to_h).to_s
  config.rp_name = 'TheaterKultur Kaisersesch'
end
