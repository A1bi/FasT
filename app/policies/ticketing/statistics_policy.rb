# frozen_string_literal: true

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

    def map_data?
      user_admin?
    end

    def check_ins?
      user_admin?
    end
  end
end
