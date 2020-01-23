module Api
  module Ticketing
    module BoxOffice
      class BaseController < ApiController
        include Authenticatable

        private

        def current_box_office
          @current_box_office ||= ::Ticketing::BoxOffice::BoxOffice.first
        end
      end
    end
  end
end
