class UserContext
  attr_reader :user, :retail_store

  def initialize(user:, retail_store: nil)
    @user = user
    @retail_store = retail_store
  end
end
