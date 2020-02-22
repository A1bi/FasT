# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class EventsController < BaseController
        def index
          @events = ::Ticketing::Event.current
        end
      end
    end
  end
end
