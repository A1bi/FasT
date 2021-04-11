# frozen_string_literal: true

module Members
  DashboardPolicy = Struct.new(:user, :dashboard) do
    def index?
      user.try(:member?)
    end

    def videos?
      index?
    end
  end
end
