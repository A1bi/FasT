# frozen_string_literal: true

module Ticketing
  class AnonymizeOrdersJob < ApplicationJob
    WAITING_PERIOD = 6.weeks

    def perform
      orders.find_each do |order|
        next unless order_anonymizable?(order)

        order.anonymize!
        order.bank_transactions.each(&:anonymize!)
      end
    end

    private

    def orders
      Ticketing::Web::Order
        .unanonymized
        .joins(tickets: :date)
        .where(ticketing_event_dates: { date: ...WAITING_PERIOD.ago })
        .distinct
    end

    def order_anonymizable?(order)
      return false unless order.billing_account.settled?

      tickets = order.tickets
      # if the order only contains tickets with the same date, it is
      # already covered by the orders query
      return true if tickets.pluck(:date_id).uniq.one?

      # no other ticket with a date not to be anonymized yet is present
      tickets
        .joins(:date)
        .where(ticketing_event_dates: { date: WAITING_PERIOD.ago.. })
        .none?
    end
  end
end
