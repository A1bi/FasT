# frozen_string_literal: true

module Members
  class MembershipApplicationPolicy < ApplicationPolicy
    def index?
      user_permitted?(:members_read)
    end

    def show?
      index?
    end

    def destroy?
      user_permitted?(:members_update) && record.open?
    end
  end
end
