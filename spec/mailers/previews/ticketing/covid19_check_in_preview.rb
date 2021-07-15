# frozen_string_literal: true

module Ticketing
  class Covid19CheckInPreview < ActionMailer::Preview
    def check_in
      event = Event.find_by!(covid19: true)
      ticket = Ticket.find_by!(date: event.dates)
      Covid19CheckInMailer.check_in(ticket)
    end
  end
end
