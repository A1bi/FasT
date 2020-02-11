module Newsletter
  class ImagePolicy < ApplicationPolicy
    def create?
      user_admin? && !record.newsletter.sent?
    end

    def destroy?
      create?
    end
  end
end
