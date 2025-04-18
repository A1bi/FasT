# frozen_string_literal: true

module Ticketing
  class Event < ApplicationRecord
    include Statistics

    has_many :dates, -> { order(:date) }, class_name: 'EventDate', inverse_of: :event, dependent: :destroy
    has_many :ticket_types, dependent: :destroy
    has_many :tickets, through: :ticket_types
    has_many :reservations, through: :dates
    belongs_to :location
    belongs_to :seating, optional: true

    validates :identifier, :assets_identifier, :slug, :admission_duration, presence: true
    validates :identifier, :slug, uniqueness: true
    validate :seating_or_number_of_seats_present, if: :ticketing_enabled?

    before_validation :set_assets_identifier, on: :create
    before_validation :set_slug, on: :create
    before_validation :remove_number_of_seats_with_seating

    default_scope { ticketing_enabled }

    class << self
      def ticketing_enabled
        where(ticketing_enabled: true)
      end

      def including_ticketing_disabled
        unscope(where: :ticketing_enabled)
      end

      def with_future_dates(offset: 0.days)
        join_dates.merge(EventDate.upcoming(offset:).uncancelled)
      end

      def on_sale
        where(sale_start: ..Time.current).with_future_dates
      end

      def ordered_by_dates(order = :asc)
        join_dates.order("MIN(ticketing_event_dates.date) #{order}")
      end

      def with_seating
        where.not(seating: nil)
      end

      def archived
        join_dates.merge(EventDate.past.uncancelled).where("(info->>'archived')::boolean = ?", true)
                  .where.not(id: with_future_dates)
      end

      private

      def join_dates
        left_joins(:dates).group(:id)
      end
    end

    def past?
      dates.maximum(:date).past?
    end

    def sold_out?
      dates.all? { |date| (ticket_stats_for_event(self).dig(:total, date.id, :percentage) || 0) >= 100 }
    end

    def sale_not_yet_started?
      sale_start&.future?
    end

    def sale_started?
      ticketing_enabled? && (sale_start.nil? || sale_start.past?)
    end

    alias sale_ended? past?

    def on_sale?
      sale_started? && !sale_ended?
    end

    def sale_disabled?
      sale_disabled_message.present?
    end

    def free?
      ticket_types.count.positive? && ticket_types.sum(:price).zero?
    end

    def seating?
      seating.present?
    end

    def number_of_seats
      seating? ? seating.number_of_seats : super
    end

    %i[main_gallery header_gallery].each do |attribute|
      define_method attribute do
        return if info["#{attribute}_id"].blank?

        Gallery.find_by(id: info["#{attribute}_id"])
      end
    end

    private

    def set_assets_identifier
      self.assets_identifier = identifier if assets_identifier.blank?
    end

    def set_slug
      self.slug = name&.parameterize if slug.blank?
    end

    def remove_number_of_seats_with_seating
      self.number_of_seats = nil if seating?
    end

    def seating_or_number_of_seats_present
      errors.add(:number_of_seats, :blank_without_seating) unless seating? || self[:number_of_seats].present?
    end
  end
end
