module Kernel
  def suppress_in_production(*exception_classes)
    # exceptions should be raised in development and staging
    return yield unless Rails.env.production?

    # suppress exceptions in production and only report to Sentry
    begin
      yield
    rescue *exception_classes => e
      Raven.capture_exception(e)
    end
  end
end
