# frozen_string_literal: true

module Members
  class MembershipFeeDebitSubmissionPolicy < ApplicationPolicy
    def index?
      user_permitted?(:members_read)
    end

    def show?
      index?
    end
  end
end
