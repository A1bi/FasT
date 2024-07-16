# frozen_string_literal: true

module Ticketing
  class ChosenSeatsService
    def initialize(socket_id)
      @socket_id = socket_id
    end

    def seats
      @seats ||= if seat_ids.nil?
                   []
                 else
                   Seat.where(id: seat_ids).order(:block_id, :number).to_a
                 end
    end

    def next
      seats.shift
    end

    private

    def seat_ids
      @seat_ids = if @socket_id.blank?
                    nil
                  else
                    ids = NodeApi.get_chosen_seats(@socket_id)
                    create_sentry_breadcrumb(ids)
                    ids
                  end
    end

    def create_sentry_breadcrumb(ids)
      info = if ids.nil?
               { message: 'Unknown socket id', type: 'error', level: 'error' }
             else
               { message: 'Received chosen seats from node', type: 'debug', data: { seats: ids.dup } }
             end
      crumb = Sentry::Breadcrumb.new(**info)
      Sentry.add_breadcrumb(crumb)
    end
  end
end
