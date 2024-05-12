# frozen_string_literal: true

module Ticketing
  class ProcessReceivedTransferPaymentsJob < ApplicationJob
    def perform
      ReceivedTransferPaymentProcessService.new.execute
    end
  end
end
