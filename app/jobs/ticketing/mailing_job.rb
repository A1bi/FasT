module Ticketing
  class MailingJob  < ApplicationJob
    queue_as :mailing

    def perform(order_id, action, options = nil)
      order = Ticketing::Web::Order.find(order_id)
      OrderMailer.order_action(action, order, options).deliver_now
    end
  end
end
