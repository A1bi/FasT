class PhotoPolicy < ApplicationPolicy
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
