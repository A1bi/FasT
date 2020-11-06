# frozen_string_literal: true

InternetAccessSessionPolicy = Struct.new(:user, :internet_access_session) do
  def new?
    true
  end

  def create?
    user.permitted?(:internet_access_sessions_create)
  end
end
