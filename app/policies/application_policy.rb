# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    def user_admin?
      user.try(:admin?)
    end

    def user_retail?
      user.try(:retail?)
    end
  end

  private

  def user_permitted?(action, web_authn_required: Settings.admin.web_authn_required)
    user&.permitted?(action) && (!web_authn_required || user.web_authn_set_up?)
  end

  def user_admin?(web_authn_required: Settings.admin.web_authn_required)
    user.try(:admin?) && (!web_authn_required || user.web_authn_set_up?)
  end

  def user_member?
    user.try(:member?)
  end

  def user_retail?
    user.try(:retail?)
  end

  def user_retail_store
    user.try(:store)
  end
end
