class PhotoPolicy < ApplicationPolicy
  def show?
    current_user_member?
  end

  def create?
    current_user_admin?
  end

  def update?
    current_user_admin?
  end

  def destroy?
    current_user_admin?
  end

  def sort?
    current_user_admin?
  end
end
