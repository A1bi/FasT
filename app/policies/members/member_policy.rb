module Members
  class MemberPolicy < ApplicationPolicy
    def update?
      current_user_member?
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
