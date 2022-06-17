# frozen_string_literal: true

Sentry.init do |config|
  app = Rails.application
  config.dsn = app.credentials.sentry[:dsn] if Settings.sentry.enabled
  config.send_default_pii = true
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.auto_session_tracking = false # not supported by GlitchTip
end
