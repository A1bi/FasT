# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis:///var/run/redis/redis.sock' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis:///var/run/redis/redis.sock' }
end
