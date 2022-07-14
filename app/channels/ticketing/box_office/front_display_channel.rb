# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class FrontDisplayChannel < ActionCable::Channel::Base
      def subscribed
        box_office = Ticketing::BoxOffice::BoxOffice.find(params[:box_office_id])
        stream_for box_office
      rescue ActiveRecord::RecordNotFound
        reject
      end
    end
  end
end
