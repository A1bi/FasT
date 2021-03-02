# frozen_string_literal: true

module Ticketing
  class BillingsController < BaseController
    before_action :find_order

    def create
      case params[:note].to_sym
      when :transfer_refund
        transfer_refund
      when :cash_refund_in_store
        cash_refund_in_store
      else
        adjust_balance
      end
      redirect_to_order_details
    end

    private

    def transfer_refund
      authorize :transfer_refund?
      billing_service.settle_balance(:transfer_refund)
    end

    def cash_refund_in_store
      authorize :cash_refund_in_store?
      billing_service.refund_in_retail_store
    end

    def adjust_balance
      authorize :adjust_balance?
      billing_service.adjust_balance(amount)
    end

    def find_order
      @order = Order.find(params[:order_id])
    end

    def authorize(action)
      super @order, action, policy_class: BillingPolicy
    end

    def billing_service
      OrderBillingService.new(@order)
    end

    def amount
      params[:amount].gsub(',', '.').to_f
    end

    def redirect_to_order_details
      flash[:notice] = t(:created, scope: %i[ticketing billings])
      redirect_to ticketing_order_path(@order)
    end
  end
end
