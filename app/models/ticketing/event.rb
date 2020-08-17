# frozen_string_literal: true

module Ticketing
  class Event < ApplicationRecord
    include Statistics

    has_many :dates, -> { order(:date) }, class_name: 'EventDate',
                                          inverse_of: :event
    has_many :ticket_types, dependent: :destroy
    belongs_to :seating

    validates :identifier, :assets_identifier, :slug, presence: true
    validates :identifier, :slug, uniqueness: true

    before_validation :set_assets_identifier, on: :create

    def self.current
      where(archived: false)
    end

    def self.with_future_dates
      joins(:dates).merge(EventDate.upcoming)
                   .where.not(ticketing_event_dates: { id: nil }).distinct
    end

    def sold_out?
      (ticket_stats_for_event(self)
        .dig(:total, :total, :percentage) || 0) >= 100
    end

    def sale_started?
      sale_start.nil? || Time.current > sale_start
    end

    def sale_ended?
      dates.maximum(:date) < Time.current
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
