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
      user_admin?
    end

    def destroy?
      update?
    end

    def mail?
      update?
    end
  end
end
