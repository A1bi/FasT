# frozen_string_literal: true

module Ticketing
  class ProcessReceivedTransferPaymentsJob < ApplicationJob
    def perform
      return unless Settings.ebics.enabled

      ReceivedTransferPaymentProcessService.new.execute
    end
  end
end
