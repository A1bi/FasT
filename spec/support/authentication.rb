# frozen_string_literal: true

module AuthenticationHelpers
  def sign_in(user: build(:user), permissions: nil, admin: false)
    user.permissions = permissions if permissions.present?
    user.group = :admin if admin
    allow_any_instance_of(ApplicationController) # rubocop:disable RSpec/AnyInstance
      .to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers
end
