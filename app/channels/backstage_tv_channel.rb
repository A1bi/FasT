# frozen_string_literal: true

class BackstageTvChannel < ActionCable::Channel::Base
  def subscribed
    stream_from :ticketing_check_ins
    stream_from :ticketing_tickets_sold
    stream_from :ticketing_seats

    Ticketing::BroadcastTicketsSoldJob.perform_later
    Ticketing::BroadcastCheckInsJob.perform_later
  end
end
