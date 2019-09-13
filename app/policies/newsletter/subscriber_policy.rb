module Newsletter
  class SubscriberPolicy < ApplicationPolicy
    def create?
      true
    end

    def update?
      true
    end

    def destroy?
      true
    end

    def confirm?
      true
    end
  end
end
