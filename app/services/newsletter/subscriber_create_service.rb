# frozen_string_literal: true

module Newsletter
  class SubscriberCreateService
    attr_accessor :params, :after_order

    def initialize(params, after_order = false)
      @params = params
      @after_order = after_order
    end

    def execute
      subscriber = Subscriber.create(params)

      if subscriber.persisted?
        subscriber.send_confirmation_instructions(
          after_order: after_order,
          delay: after_order ? 30.minutes : nil
        )
      end

      subscriber
    end
  end
end
