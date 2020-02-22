# frozen_string_literal: true

Raven.configure do |config|
  app = Rails.application
  config.dsn = app.credentials.sentry[:dsn] if Settings.sentry.enabled
  config.sanitize_fields = app.config.filter_parameters.map(&:to_s)
end
