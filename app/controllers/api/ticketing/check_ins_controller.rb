# frozen_string_literal: true

module Api
  module Ticketing
    class CheckInsController < ApiController
      include Authenticatable

      def index
        @changed_tickets = changed_tickets
        @signing_keys = ::Ticketing::SigningKey.active
        @ticket_types = ::Ticketing::TicketType.where(event: events)
        @blocks = ::Ticketing::Block.where(seating: seatings)
        @seats = ::Ticketing::Seat.where(block: @blocks)
      end

      def create
        params[:check_ins].each do |check_in|
          ::Ticketing::TicketCheckInJob.perform_later(
            **check_in.permit(:ticket_id, :date, :medium).to_h.symbolize_keys
          )
        end
        head :created
      end

      private

      def events
        @events ||= ::Ticketing::Event.with_future_dates(offset: 1.day)
      end

      def dates
        @dates ||= ::Ticketing::EventDate.where(event: events)
      end

      def changed_tickets
        ::Ticketing::Ticket.where(date: dates).where('created_at != updated_at')
      end

      def seatings
        ::Ticketing::Seating.find(events.with_seating.pluck(:seating_id))
      end

      def auth_token
        super || Rails.application.credentials.ticketing_api_auth_token
      end
    end
  end
end
