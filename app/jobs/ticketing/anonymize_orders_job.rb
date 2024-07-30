# frozen_string_literal: true

module Ticketing
  class AnonymizeOrdersJob < ApplicationJob
    def perform
      Ticketing::Web::Order.anonymizable.find_each do |order|
        order.anonymize!
        order.bank_transactions.each(&:anonymize!)
      end
    end
  end
end
