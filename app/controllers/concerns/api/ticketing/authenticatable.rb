module Api
  module Ticketing
    module Authenticatable
      extend ActiveSupport::Concern

      DEVELOPMENT_TOKEN = 'foobar'.freeze

      included do
        before_action :authenticate
      end

      private

      def authenticate
        authenticate_or_request_with_http_token do |provided_token, _|
          ActiveSupport::SecurityUtils.secure_compare(provided_token, token)
        end
      end

      def token
        return DEVELOPMENT_TOKEN if Rails.env.development?

        Rails.application.credentials.ticketing_api_auth_token
      end
    end
  end
end
