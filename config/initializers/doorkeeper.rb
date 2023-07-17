# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    skip_authorization
    current_user || redirect_to_login_form
  end

  enforce_content_type

  base_controller 'ApplicationController'

  reuse_access_token

  default_scopes :read
  enforce_configured_scopes

  force_ssl_in_redirect_uri !Rails.env.development?

  allow_blank_redirect_uri false

  grant_flows %w[authorization_code]

  authorize_resource_owner_for_client do |_client, resource_owner|
    resource_owner.member?
  end

  skip_authorization { true }
end
