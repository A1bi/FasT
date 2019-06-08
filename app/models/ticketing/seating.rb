module Ticketing
  class Seating < BaseModel
    has_many :blocks, dependent: :destroy
    has_many :seats, through: :blocks
    has_one_attached :plan

    validates :name, presence: true

    after_save :create_stripped_plan
    after_destroy :remove_stripped_plan

    def bound_to_seats?
      self[:number_of_seats] < 1
    end

    def number_of_seats
      bound_to_seats? ? seats.count : self[:number_of_seats]
    end

    def unreserved_seats_on_date(date)
      return seats unless bound_to_seats?

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
      bound_to_seats? ? unreserved_seats_on_date(date).count : self[:number_of_seats]
    end

    def plan_path(stripped: true, absolute: false)
      return unless plan.attached?
      if stripped
        path = Rails.root.join('public') if absolute
        File.join(path || '', 'system', 'seatings', "#{id}-#{stripped_plan_digest}.svg")
      else
        ActiveStorage::Blob.service.send(:path_for, plan.key)
      end
    end

    private

    def create_stripped_plan
      return if !plan.attached? || (stripped_plan_digest.present? && !plan.saved_changes?)

      svg = File.open(plan_path(stripped: false)) { |f| Nokogiri::XML(f) }

      svg.xpath('//bx:*').remove
      svg.xpath('//*/@bx:*').remove
      svg.xpath('//title').remove

      xml = svg.to_xml
      # remove namespace, nokogiri does not seem to support removal of namespaces
      xml.sub!(/xmlns:bx=".+?"/, '')
      # remove titles
      xml.gsub!(%r{<title>.+?</title>}i, '')
      # remove whitespace
      xml.gsub!(/([>\n\r])\s+([<\n\r])/i, '\1\2')

      # remove old plan
      path = plan_path(stripped: true, absolute: true)
      FileUtils.rm_f([path, "#{path}.gz"])

      update_column(:stripped_plan_digest, Digest::MD5.hexdigest(xml)) # rubocop:disable Rails/SkipsModelValidations

      path = plan_path(stripped: true, absolute: true)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.write xml }
      Zlib::GzipWriter.open("#{path}.gz") { |gz| gz.write xml }
    end

    def remove_stripped_plan
      return unless plan.attached?

      path = plan_path(stripped: true, absolute: true)
      FileUtils.rm_f([path, "#{path}.gz"])
    end
  end
end
