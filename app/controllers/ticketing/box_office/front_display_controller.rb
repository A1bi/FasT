# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class FrontDisplayController < BaseController
      skip_authorization only: :index
      layout 'minimal'

      def index
        @events = Ticketing::Event.with_future_dates
      end
    end
  end
end
