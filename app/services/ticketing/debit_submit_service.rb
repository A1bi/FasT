# frozen_string_literal: true

module Ticketing
  class DebitSubmitService
    def initialize(orders, current_user: nil)
      @orders = orders
      @current_user = current_user
    end

    def execute
      submission = BankSubmission.new
      submission.transaction do
        @orders.each do |order|
          next if order.bank_charge.submitted?

          payment_service(order).submit_charge
          submission.charges << order.bank_charge
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
