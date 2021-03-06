# frozen_string_literal: true

module Ticketing
  class OrderPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user_admin?
          scope.all
        elsif user_retail?
          user.store.orders
        else
          scope.none
        end
      end
    end

    def index?
      user_admin? || user_retail?
    end

    def new?
      true
    end

    def new_coupons?
      true
    end

    def new_privileged?
      user_admin? || user_retail?
    end

    def enable_reservation_groups?
      user_admin?
    end

    def show?
      user_admin? || retail_order?
    end

    def seats?
      show?
    end

    def update?
      user_admin? && record.is_a?(Web::Order)
    end

    def edit?
      update?
    end

    def mark_as_paid?
      user_admin?
    end

    def send_pay_reminder?
      user_admin?
    end

    def resend_confirmation?
      user_admin?
    end

    def resend_items?
      user_admin?
    end

    private

    def retail_order?
      record.try(:store) && record.store == user_retail_store
    end
  end
end
