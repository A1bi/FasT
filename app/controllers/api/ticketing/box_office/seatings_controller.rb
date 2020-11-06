# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class SeatingsController < BaseController
        before_action :find_event

        def show
          render :show, layout: 'minimal'
        end

        private

        def find_event
          @event = ::Ticketing::Event.current.find(params[:event_id])
        end
      end
    end
  end
end
