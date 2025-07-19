# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class BoxOfficeChannel < ActionCable::Channel::Base
      def subscribed
        stream_from :ticketing_check_ins
        stream_from :ticketing_tickets_sold

        Ticketing::BroadcastTicketsSoldJob.perform_later
        Ticketing::BroadcastCheckInsJob.perform_later
      end
    end
  end
end
