# frozen_string_literal: true

module Ticketing
  class SeatingPolicy < ApplicationPolicy
    def index?
      user_admin?
    end

    def show?
      user_admin?
    end
  end
end
