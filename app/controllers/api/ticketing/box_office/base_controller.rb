# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class BaseController < ApiController
        include Authenticatable

        private

        def current_box_office
          @current_box_office ||= ::Ticketing::BoxOffice::BoxOffice.first
        end

        def auth_token
          super || Rails.application.credentials.ticketing_api_auth_token
        end
      end
    end
  end
end
