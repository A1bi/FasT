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
      user_admin?
    end

    def destroy?
      user_admin?
    end

    def finish?
      user_admin?
    end
  end
end
