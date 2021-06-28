# frozen_string_literal: true

module Members
  class MemberPolicy < ApplicationPolicy
    def index?
      user_permitted?(:members_read)
    end

    def create?
      update_permitted?
    end

    def show?
      index?
    end

    def show_permissions?
      user_permitted?(:permissions_read)
    end

    def update?
      user.present? && record.member? && record == user || update_permitted?
    end

    def update_permissions?
      user_permitted?(:permissions_update)
    end

    def destroy?
      user_permitted?(:members_destroy)
    end

    def reactivate?
      update_permitted?
    end

    def resume_membership_fee_payments?
      update_permitted?
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
      attrs = if user_admin?
                %i[email first_name last_name nickname gender title street plz
                   city phone birthday family_member_id family_id joined_at
                   group sepa_mandate_id membership_fee]
              else
                %i[email password password_confirmation]
              end

      attrs << { permissions: [], shared_email_accounts_authorized_for: [] } if update_permissions?

      attrs
    end

    private

    def update_permitted?
      user_permitted?(:members_update)
    end
  end
end
