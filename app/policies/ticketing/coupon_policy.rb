module Ticketing
  class CouponPolicy < ApplicationPolicy
    def index?
      current_user_member?
    end

    def show?
      index?
    end

    def create?
      current_user_admin?
    end

    def update?
      current_user_admin?
    end

    def destroy?
      update?
    end

    def mail?
      update?
    end
  end
end
