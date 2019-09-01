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

    def finish?
      true
    end
  end
end
