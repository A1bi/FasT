module Members
  DashboardPolicy = Struct.new(:user, :dashboard) do
    def index?
      true
    end
  end
end
