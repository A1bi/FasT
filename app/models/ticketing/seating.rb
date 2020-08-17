# frozen_string_literal: true

module Ticketing
  class Seating < ApplicationRecord
    has_many :blocks, dependent: :destroy
    has_many :seats, through: :blocks
    has_many :events, dependent: :nullify
    has_one_attached :plan

    validates :name, presence: true

    after_destroy :remove_stripped_plan
    after_commit :create_stripped_plan, on: %i[create update]

    class << self
      def with_plan
        includes(:plan_attachment)
          .where.not(active_storage_attachments: { id: nil })
      end
    end

    def plan?
      plan.attached?
    end

    def number_of_seats
      plan? ? seats.count : self[:number_of_seats]
    end

    def unreserved_seats_on_date(date)
      return seats unless plan?

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

    def number_of_unreserved_seats_on_date(date)
      plan? ? unreserved_seats_on_date(date).count : self[:number_of_seats]
    end

    def stripped_plan_url
      return unless plan.attached?

      "/system/seatings/#{stripped_plan_filename}"
    end

    def stripped_plan_path
      return unless plan.attached?

      Rails.root.join('public', 'system', 'seatings', stripped_plan_filename)
    end

    private

    def create_stripped_plan
      return if !plan.attached? ||
                (stripped_plan_digest.present? && !plan.saved_changes?)

      svg = Nokogiri::XML(plan_content)

      svg.xpath('//bx:*').remove
      svg.xpath('//*/@bx:*').remove
      svg.xpath('//title').remove

      xml = svg.to_xml
      # nokogiri does not seem to support removal of namespaces
      xml.sub!(/xmlns:bx=".+?"/, '')
      # remove titles
      xml.gsub!(%r{<title>.+?</title>}i, '')
      # remove whitespace
      xml.gsub!(/([>\n\r])\s+([<\n\r])/i, '\1\2')

      # remove old plan
      path = stripped_plan_path
      FileUtils.rm_f([path, "#{path}.gz"])

      update_column(:stripped_plan_digest, Digest::MD5.hexdigest(xml)) # rubocop:disable Rails/SkipsModelValidations

      path = stripped_plan_path
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.write xml }
      Zlib::GzipWriter.open("#{path}.gz") { |gz| gz.write xml }
    end

    def remove_stripped_plan
      return unless plan.attached?

      path = stripped_plan_path
      FileUtils.rm_f([path, "#{path}.gz"])
    end

    def stripped_plan_filename
      "#{id}-#{stripped_plan_digest}.svg"
    end

    def plan_content
      plan.download
    rescue ActiveStorage::FileNotFoundError
      # see https://github.com/rails/rails/pull/37005
      attachment_changes['plan'].attachable[:io].string
    end
  end
end
