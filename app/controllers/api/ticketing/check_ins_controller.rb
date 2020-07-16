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
        ActiveRecord::Base.transaction do
          params[:check_ins].each do |check_in|
            ticket = ::Ticketing::Ticket.find(check_in[:ticket_id])
            next if ticket.check_ins.create(check_in.permit(:date, :medium))

            raise ActiveRecord::RecordInvalid
          end
        end

        head :created
      rescue ActiveRecord::RecordInvalid
        head :unprocessable_entity
      end

      private

      def events
        @events ||= ::Ticketing::Event.current
      end

      def dates
        @dates ||= ::Ticketing::EventDate.where(event: events)
      end

      def covid19_dates
        ::Ticketing::EventDate.where(event: events.where(covid19: true))
      end

      def changed_tickets
        ::Ticketing::Ticket.where(date: dates)
                           .where('created_at != updated_at')
                           .or(::Ticketing::Ticket.where(date: covid19_dates))
      end

      def seatings
        ::Ticketing::Seating.find(events.pluck(:seating_id))
      end

      def auth_token
        super || Rails.application.credentials.ticketing_api_auth_token
      end
    end
  end
end
