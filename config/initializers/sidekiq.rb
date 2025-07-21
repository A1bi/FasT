# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = Settings.redis
end

Sidekiq.configure_client do |config|
  config.redis = Settings.redis
end
