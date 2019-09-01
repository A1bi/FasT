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

    def permitted_attributes
      if current_user_admin?
        %i[email first_name last_name nickname street plz city phone birthday
           family_member_id family_id joined_at group sepa_mandate_id]
      else
        %i[email password password_confirmation]
      end
    end
  end
end
