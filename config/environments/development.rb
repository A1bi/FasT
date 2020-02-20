Rails.application.configure do
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.assets.debug = true

  config.eager_load = false

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
