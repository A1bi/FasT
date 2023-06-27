# frozen_string_literal: true

module Ticketing
  class Event < ApplicationRecord
    include Statistics

    has_many :dates, -> { order(:date) }, class_name: 'EventDate', inverse_of: :event, dependent: :destroy
    has_many :ticket_types, dependent: :destroy
    has_many :tickets, through: :ticket_types
    has_many :reservations, through: :dates
    belongs_to :location
    belongs_to :seating

    validates :identifier, :assets_identifier, :slug, :admission_duration, presence: true
    validates :identifier, :slug, uniqueness: true

    before_validation :set_assets_identifier, on: :create

    class << self
      def current
        where(archived: false)
      end

      def with_future_dates
        joins(:dates).merge(EventDate.upcoming.uncancelled).group(:id)
      end

      def ordered_by_dates(order = :asc)
        joins(:dates).order("MIN(ticketing_event_dates.date) #{order}").group(:id)
      end
    end

    def sold_out?
      (ticket_stats_for_event(self).dig(:total, :total, :percentage) || 0) >= 100
    end

    def sale_not_yet_started?
      sale_start&.future?
    end

    def sale_started?
      sale_start.nil? || sale_start.past?
    end

    def sale_ended?
      dates.maximum(:date).past?
    end

    def on_sale?
      sale_started? && !sale_ended?
    end

    def sale_disabled?
      sale_disabled_message.present?
    end

    private

    def set_assets_identifier
      self.assets_identifier ||= identifier
    end
  end
end
