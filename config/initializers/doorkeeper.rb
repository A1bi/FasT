# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    raise "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by(id: session[:user_id]) || redirect_to(new_user_session_url)
  end

  enforce_content_type

  # The controller +Doorkeeper::ApplicationController+ inherits from.
  # Defaults to +ActionController::Base+ unless +api_only+ is set, which changes the default to
  # +ActionController::API+. The return value of this option must be a stringified class name.
  # See https://doorkeeper.gitbook.io/guides/configuration/other-configurations#custom-controllers
  #
  # base_controller 'ApplicationController'

  reuse_access_token

  # Issue access tokens with refresh token (disabled by default), you may also
  # pass a block which accepts `context` to customize when to give a refresh
  # token or not. Similar to +custom_access_token_expires_in+, `context` has
  # the following properties:
  #
  # `client` - the OAuth client application (see Doorkeeper::OAuth::Client)
  # `grant_type` - the grant type of the request (see Doorkeeper::OAuth)
  # `scopes` - the requested scopes (see Doorkeeper::OAuth::Scopes)
  #
  # use_refresh_token

  default_scopes :read
  # optional_scopes :write
  enforce_configured_scopes

  force_ssl_in_redirect_uri !Rails.env.development?

  allow_blank_redirect_uri false

  # Customize token introspection response.
  # Allows to add your own fields to default one that are required by the OAuth spec
  # for the introspection response. It could be `sub`, `aud` and so on.
  # This configuration option can be a proc, lambda or any Ruby object responds
  # to `.call` method and result of it's invocation must be a Hash.
  #
  # custom_introspection_response do |token, context|
  #   {
  #     "sub": "Z5O3upPC88QrAjx00dis",
  #     "aud": "https://protected.example.net/resource",
  #     "username": User.find(token.resource_owner_id).username
  #   }
  # end

  grant_flows %w[authorization_code]

  authorize_resource_owner_for_client do |_client, _resource_owner|
    resource_owner.member?
  end

  skip_authorization do |_resource_owner, _client|
    true
  end
end
