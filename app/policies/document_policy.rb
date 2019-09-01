class DocumentPolicy < ApplicationPolicy
  def create?
    current_user_admin?
  end

  def update?
    current_user_admin?
  end

  def destroy?
    current_user_admin?
  end
end
