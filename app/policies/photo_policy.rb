# frozen_string_literal: true

class PhotoPolicy < ApplicationPolicy
  def index?
    true
  end

  # download photo
  def show?
    user_member?
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

  def sort?
    user_admin?
  end
end
