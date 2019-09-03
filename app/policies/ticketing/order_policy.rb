module Ticketing
  class OrderPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if current_user_admin?
          scope.all
        elsif retail_store
          retail_store.orders
        end
      end
    end

    def index?
      current_user_admin? || retail_store
    end

    def new?
      true
    end

    def new_admin?
      current_user_admin?
    end

    def new_retail?
      retail_store
    end

    def add_coupon?
      true
    end

    def remove_coupon?
      true
    end

    def enable_reservation_groups?
      current_user_admin?
    end

    def show?
      current_user_admin? || retail_order?
    end

    def seats?
      show?
    end

    def update?
      current_user_admin?
    end

    def edit?
      update?
    end

    def mark_as_paid?
      update?
    end

    def credit_transfer_file?
      current_user_admin?
    end

    def send_pay_reminder?
      current_user_admin?
    end

    def resend_confirmation?
      current_user_admin?
    end

    def resend_tickets?
      current_user_admin?
    end

    def cash_refund_in_store?
      current_user_admin? || retail_order?
    end

    def transfer_refund?
      current_user_admin?
    end

    def correct_balance?
      current_user_admin?
    end

    private

    def retail_order?
      record.try(:store) == retail_store
    end
  end
end
