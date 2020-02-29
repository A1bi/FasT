# frozen_string_literal: true

module Newsletter
  class NewsletterPolicy < ApplicationPolicy
    def index?
      user_admin?
    end

    def show?
      user_admin?
    end

    def create?
      user_admin?
    end

    def update?
      user_admin? && can_be_modified?
    end

    def destroy?
      user_admin? && can_be_modified?
    end

    def finish?
      user_admin?
    end

    def approve?
      # TODO: change this
      user.id == 1
    end

    private

    def can_be_modified?
      record.draft?
    end
  end
end
