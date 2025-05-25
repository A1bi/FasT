# frozen_string_literal: true

module Ticketing
  class SeatingPolicy < ApplicationPolicy
    def index?
      user_admin?(web_authn_required: false)
    end

    def show?
      index?
    end
  end
end
