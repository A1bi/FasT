module Ticketing
  class StatisticsPolicy < ApplicationPolicy
    def index?
      current_user_admin?
    end

    def index_retail?
      retail_store
    end

    def seats?
      current_user_admin?
    end

    def chart_data?
      current_user_admin?
    end
  end
end
