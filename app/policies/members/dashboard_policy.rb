# frozen_string_literal: true

module Members
  DashboardPolicy = Struct.new(:user, :dashboard) do
    def index?
      user.try(:member?)
    end
  end
end
