# frozen_string_literal: true

module Ticketing
  class BillingsController < BaseController
    ALLOWED_BILLABLE_TYPES = %w[Order Coupon].freeze

    def create
      if create_billing
        flash.notice = t('.created')
      else
        flash.alert = t('.not_created')
      end
      redirect_to billable.becomes(billable.class.base_class)
    end

    private

    def create_billing
      case billable
      when Order
        case params[:note].to_sym
        when :refund_to_most_recent_bank_account
          refund_to_bank_account(use_most_recent: true)
        when :refund_to_new_bank_account
          refund_to_bank_account(params.permit(:name, :iban))
        when :refund_via_stripe
          refund_via_stripe
        when :cash_refund_in_store
          cash_refund_in_store
        else
          adjust_balance
        end
      when Coupon
        adjust_value if params[:note] == 'correction'
      end
    end

    def refund_to_bank_account(params)
      authorize :refund?
      refund_service.execute(params)
    end

    def refund_via_stripe
      authorize :refund?
      refund_service.execute
    end

    def cash_refund_in_store
      authorize :cash_refund_in_store?
      billing_service.refund_in_retail_store
    end

    def adjust_balance
      authorize :adjust_balance?
      billing_service.adjust_balance(params[:amount].to_f)
    end

    def adjust_value
      authorize :adjust_value?
      billable.deposit_into_account(params[:amount].to_i, :correction)
    end

    def billable
      raise ActiveRecord::RecordNotFound unless ALLOWED_BILLABLE_TYPES.include?(params[:billable_type])

      @billable ||= "Ticketing::#{params[:billable_type]}".constantize.find(params[:billable_id])
    end

    def authorize(action)
      super(billable, action, policy_class: BillingPolicy)
    end

    def refund_service
      OrderRefundService.new(billable)
    end

    def billing_service
      OrderBillingService.new(billable)
    end
  end
end
