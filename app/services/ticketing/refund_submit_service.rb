# frozen_string_literal: true

module Ticketing
  class RefundSubmitService
    def initialize(orders, current_user: nil)
      @orders = orders
      @current_user = current_user
    end

    def execute
      submission = BankRefundSubmission.new
      submission.transaction do
        @orders.each do |order|
          next if order.open_bank_refund.nil?

          payment_service(order).submit_refund
          submission.refunds << order.open_bank_refund
        end
        submission.save!
      end
    end

    private

    def payment_service(order)
      OrderPaymentService.new(order, current_user: @current_user)
    end
  end
end
