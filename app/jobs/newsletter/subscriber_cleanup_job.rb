# frozen_string_literal: true

module Newsletter
  class SubscriberCleanupJob < ApplicationJob
    def perform
      Subscriber.expired.each(&:destroy!)
    end
  end
end
