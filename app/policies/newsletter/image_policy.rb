module Newsletter
  class ImagePolicy < ApplicationPolicy
    def create?
      current_user_admin? && !record.newsletter.sent?
    end

    def destroy?
      create?
    end
  end
end
