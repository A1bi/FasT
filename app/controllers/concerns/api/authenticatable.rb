# frozen_string_literal: true

module Api
  module Authenticatable
    extend ActiveSupport::Concern

    DEVELOPMENT_TOKEN = 'foobar'

    included do
      before_action :authenticate
    end

    private

    def authenticate
      raise 'Auth token missing for this controller' if auth_token.blank?

      authenticate_or_request_with_http_token do |provided_token, _|
        ActiveSupport::SecurityUtils.secure_compare(provided_token, auth_token)
      end
    end

    def auth_token
      DEVELOPMENT_TOKEN if Rails.env.local?
    end
  end
end
