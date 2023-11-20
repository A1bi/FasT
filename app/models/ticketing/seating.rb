# frozen_string_literal: true

module Ticketing
  class Seating < ApplicationRecord
    has_many :blocks, dependent: :destroy
    has_many :seats, through: :blocks
    has_many :events, dependent: :nullify
    has_attached_file :plan, styles: { stripped: true },
                             processors: %i[seating_plan_stripper],
                             url: '/system/:class/:attachment/:id/:style.svg'

    validates :name, presence: true
    validates_attachment :plan, content_type: { content_type: 'image/svg+xml' }

    before_destroy :remove_gzip_stripped_plan, prepend: true
    after_commit :gzip_stripped_plan

    def number_of_seats
      seats.count
    end

    def unreserved_seats_on_date(date)
      seats = Ticketing::Seat.arel_table
      reservations = Ticketing::Reservation.arel_table
      tickets = Ticketing::Ticket.arel_table
      join = seats
             .join(tickets, Arel::Nodes::OuterJoin)
             .on(
               tickets[:seat_id].eq(seats[:id])
                 .and(tickets[:date_id].eq(date.id))
                 .and(tickets[:cancellation_id].eq(nil))
             )
             .join(reservations, Arel::Nodes::OuterJoin)
             .on(
               reservations[:seat_id].eq(seats[:id])
               .and(reservations[:date_id].eq(date.id))
               .and(tickets[:id].eq(nil))
             )
             .join_sources

      self.seats.joins(join).where(reservations[:id].eq(nil)).distinct
    end

    def stripped_plan_path
      plan.path(:stripped)
    end

    private

    def gzip_stripped_plan
      return unless saved_change_to_attribute?(:plan_updated_at) && plan_updated_at.present?

      Zlib::GzipWriter.open(gzip_stripped_plan_path) do |gz|
        gz.write File.read(stripped_plan_path)
      end
    end

    def remove_gzip_stripped_plan
      FileUtils.rm_f(gzip_stripped_plan_path)
    end

    def gzip_stripped_plan_path
      "#{stripped_plan_path}.gz"
    end
  end
end
