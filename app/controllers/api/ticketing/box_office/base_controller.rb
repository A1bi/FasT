module Api
  module Ticketing
    module BoxOffice
      class BaseController < ApplicationController
        ignore_authenticity_token

        private

        def current_box_office
          @current_box_office ||= ::Ticketing::BoxOffice::BoxOffice.first
        end
      end
    end
  end
end
