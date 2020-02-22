# frozen_string_literal: true

module Members
  class DatePolicy < ApplicationPolicy
    def index?
      true
    end

    def create?
      user_admin?
    end

    def update?
      user_admin?
    end

    def destroy?
      user_admin?
    end
  end
end
