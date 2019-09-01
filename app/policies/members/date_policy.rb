module Members
  class DatePolicy < ApplicationPolicy
    def index?
      true
    end

    def create?
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
