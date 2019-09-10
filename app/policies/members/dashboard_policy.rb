module Members
  DashboardPolicy = Struct.new(:user_context, :dashboard) do
    def index?
      user_context.user.is_a? Member
    end
  end
end
