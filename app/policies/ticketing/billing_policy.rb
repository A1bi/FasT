# frozen_string_literal: true

module Ticketing
  class BillingPolicy < ApplicationPolicy
    def adjust_balance?
      user_admin?
    end

    def cash_refund_in_store?
      user_admin? || (user_retail? && record.is_a?(Retail::Order))
    end

    def transfer_refund?
      user_admin?
    end

    def adjust_value?
      user_admin?
    end
  end
end
