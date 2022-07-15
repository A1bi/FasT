# frozen_string_literal: true

module Ticketing
  class BillingsController < BaseController
    ALLOWED_BILLABLE_TYPES = %w[Order Coupon].freeze

    def create
      case billable
      when Order
        case params[:note].to_sym
        when :transfer_refund
          transfer_refund
        when :cash_refund_in_store
          cash_refund_in_store
        else
          adjust_balance
        end
      when Coupon
        adjust_value if params[:note] == 'correction'
      end
      redirect_to_billable
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
      super billable, action, policy_class: BillingPolicy
    end

    def billing_service
      OrderBillingService.new(billable)
    end

    def redirect_to_billable
      flash[:notice] = t('ticketing.billings.created')
      redirect_to billable.becomes(billable.class.base_class)
    end
  end
end
