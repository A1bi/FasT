module Ticketing
  class ReservationGroupPolicy < ApplicationPolicy
    def index?
      current_user_admin?
    end

    def create?
      current_user_admin?
    end

    def show?
      current_user_admin?
    end

    def update?
      current_user_admin?
    end

    def destroy?
      current_user_admin?
    end
  end
end
