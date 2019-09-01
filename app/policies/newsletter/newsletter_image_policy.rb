module Newsletter
  class NewsletterImagePolicy < ApplicationPolicy
    def create?
      current_user_admin?
    end

    def destroy?
      current_user_admin?
    end
  end
end
