# frozen_string_literal: true

module Admin
  class WasserwerkPolicy < ApplicationPolicy
    def index?
      user_permitted?(:wasserwerk_read, web_authn_required: false)
    end

    def update?
      user_permitted?(:wasserwerk_update)
    end
  end
end
