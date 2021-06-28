# frozen_string_literal: true

module AuthenticationHelpers
  def sign_in(user: build(:user), permissions: nil, admin: false)
    user.permissions = permissions if permissions.present?
    user.group = :admin if admin
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
  end

  def sign_in_api
    allow_any_instance_of(ApplicationController).to receive(:authenticate_or_request_with_http_token) # rubocop:disable RSpec/AnyInstance
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers
end

RSpec.shared_examples 'redirect unauthenticated' do
  it 'redirects to the login page' do
    subject
    expect(response).to redirect_to(login_path)
  end
end

RSpec.shared_examples 'redirect unauthorized' do
  it 'redirects to the login page' do
    subject
    expect(response).to redirect_to(root_path)
  end
end
