# frozen_string_literal: true

module Doorkeeper
  class EnhancedTokenInfoController < TokenInfoController
    protected

    def doorkeeper_token_to_json
      doorkeeper_token.as_json.merge(
        user_id: doorkeeper_token.resource_owner_id,
        email: user.email,
        full_name: user.name.full,
        groups:
      )
    end

    private

    def user
      @user ||= User.find(doorkeeper_token.resource_owner_id)
    end

    def groups
      groups = [:member]
      groups << :admin if user.admin?
      groups
    end
  end
end
