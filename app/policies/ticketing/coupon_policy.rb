# frozen_string_literal: true

module Ticketing
  class CouponPolicy < ApplicationPolicy
    def index?
      user_admin?
    end

    def show?
      index?
    end

    def create?
      user_admin?
    end

    def update?
      user_admin? && record.purchased_with_order.nil?
    end

    def destroy?
      update?
    end

    def mail?
      update?
    end

    def permitted_attributes
      %i[recipient affiliation free_tickets]
    end
  end
end
