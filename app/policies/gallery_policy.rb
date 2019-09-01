class GalleryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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
