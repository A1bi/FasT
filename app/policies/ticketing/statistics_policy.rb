module Ticketing
  class StatisticsPolicy < ApplicationPolicy
    def index?
      user_admin? || user_retail?
    end

    def seats?
      user_admin?
    end

    def chart_data?
      user_admin?
    end
  end
end
