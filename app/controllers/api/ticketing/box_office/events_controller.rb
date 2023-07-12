# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class EventsController < BaseController
        def index
          @events = ::Ticketing::Event.with_future_dates(offset: 1.day)
        end
      end
    end
  end
end
