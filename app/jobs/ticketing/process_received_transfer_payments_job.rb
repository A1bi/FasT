# frozen_string_literal: true

module Ticketing
  class ProcessReceivedTransferPaymentsJob < ApplicationJob
    def perform(intraday:)
      return unless Settings.ebics.enabled

      ReceivedTransferPaymentProcessService.new.execute(intraday:)
    end
  end
end
