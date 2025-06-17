# frozen_string_literal: true

module Ticketing
  class SendPayRemindersJob < ApplicationJob
    SEND_AFTER_DAYS = [7, 10].freeze

    def perform
      orders.each do |order|
        OrderPaymentService.new(order).send_reminder
      end
    end

    private

    def orders
      initial_scope = order_scope_for_days(SEND_AFTER_DAYS[0])
      SEND_AFTER_DAYS[1..].each_with_object(initial_scope) do |days, scope|
        scope.or!(order_scope_for_days(days))
      end
    end

    def order_scope_for_days(days)
      Web::Order.unpaid.transfer_payment
                .where(created_at: ...days.days.ago)
                .where("COALESCE(last_pay_reminder_sent_at, created_at) - created_at < '#{days} days'::interval")
    end
  end
end
