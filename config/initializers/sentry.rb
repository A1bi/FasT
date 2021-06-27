# frozen_string_literal: true

Sentry.init do |config|
  app = Rails.application
  config.dsn = app.credentials.sentry[:dsn] if Settings.sentry.enabled
  config.send_default_pii = true
end
