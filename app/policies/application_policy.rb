class UserContext
  attr_reader :user, :retail_store

  def initialize(user:, retail_store: nil)
    @user = user
    @retail_store = retail_store
  end
end

class ApplicationPolicy
  attr_reader :user, :retail_store, :record

  def initialize(user_context, record)
    @user = user_context.user
    @retail_store = user_context.retail_store
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
    attr_reader :user, :retail_store, :scope

    def initialize(user_context, scope)
      @user = user_context.user
      @retail_store = user_context.retail_store
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  private

  def current_user_admin?
    user.try(:admin?)
  end

  def current_user_member?
    user.try(:member?)
  end
end
