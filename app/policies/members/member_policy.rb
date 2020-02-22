# frozen_string_literal: true

module Members
  class MemberPolicy < ApplicationPolicy
    def index?
      user_admin?
    end

    def create?
      user_admin?
    end

    def show?
      user_admin?
    end

    def update?
      user.present? && record == user || user_admin?
    end

    def destroy?
      user_admin?
    end

    def reactivate?
      user_admin?
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
      if user_admin?
        %i[email first_name last_name nickname title street plz city phone
           birthday family_member_id family_id joined_at group sepa_mandate_id
           membership_fee]
      else
        %i[email password password_confirmation]
      end
    end
  end
end
