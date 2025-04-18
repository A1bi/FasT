# frozen_string_literal: true

module Kernel
  def suppress_in_production(*exception_classes)
    # exceptions should be raised in development and staging
    return yield unless Rails.env.production? || Rails.env.test?

    # suppress exceptions in production and only report to Sentry
    begin
      yield
    rescue *exception_classes => e
      Sentry.capture_exception(e)
    end
  end
end
