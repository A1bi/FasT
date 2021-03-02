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
