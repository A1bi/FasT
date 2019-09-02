module Ticketing
  class SeatingPolicy < ApplicationPolicy
    def index?
      current_user_admin?
    end

    def show?
      current_user_admin?
    end
  end
end
