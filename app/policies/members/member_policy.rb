module Members
  class MemberPolicy < ApplicationPolicy
    def index?
      current_user_admin?
    end

    def create?
      current_user_admin?
    end

    def update?
      record == user || current_user_admin?
    end

    def destroy?
      current_user_admin?
    end

    def reactivate?
      current_user_admin?
    end

    def activate?
      true
    end

    def finish_activation?
      true
    end

    def forgot_password?
      true
    end

    def reset_password?
      true
    end
  end
end
