# frozen_string_literal: true

module Members
  class MembershipFeePaymentPolicy < ApplicationPolicy
    def mark_as_failed?
      user_permitted?(:members_update)
    end
  end
end
