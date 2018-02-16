Raven.configure do |config|
  unless Rails.env.development?
    config.dsn = 'https://14c471d166ef460ea32f681e65427ae0:21d1a2cd34a84f19836ac06df8eecd4f@sentry.a0s.de/2'
  end
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
