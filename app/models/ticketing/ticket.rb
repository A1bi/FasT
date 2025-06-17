# frozen_string_literal: true

module Ticketing
  class Ticket < ApplicationRecord
    include Cancellable

    CANCELLABLE_UNTIL_BEFORE_DATE = 24.hours
    REFUNDABLE_FOR_AFTER_DATE = 6.weeks

    belongs_to :order, touch: true
    belongs_to :type, class_name: 'TicketType'
    belongs_to :seat, optional: true
    belongs_to :date, class_name: 'EventDate'
    has_passbook_pass
    has_many :check_ins, dependent: :nullify

    validates :seat, presence: { if: :seat_required? },
                     inclusion: { in: [nil], unless: :seat_required? }
    validates :order_index, uniqueness: { scope: :order_id }
    validate :seat_available, if: :seat_required?
    validate :seat_exists_for_event, if: :seat_required?
    validate :type_exists_for_event
    validate :valid_date
    validate :event_ticketing_enabled

    before_validation :update_invalidated

    delegate :event, to: :date, allow_nil: true
    delegate :block, to: :seat, allow_nil: true
    delegate :seating, to: :event, allow_nil: true
    delegate :vat_rate, to: :type

    class << self
      def valid
        where(invalidated: false)
      end
    end

    def type=(type)
      super
      update_price
    end

    def type_id=(type)
      super
      update_price
    end

    def number
      "#{order.number}-#{self[:order_index]}"
    end

    def resold?
      return false if seat.blank?

      seat.taken?(date)
    end

    def customer_cancellable?
      !cancelled? && (
        ((date.cancelled? || exceptionally_customer_cancellable?) && (date.date + REFUNDABLE_FOR_AFTER_DATE).future?) ||
        (date.date - CANCELLABLE_UNTIL_BEFORE_DATE).future?
      )
    end

    def date_customer_transferable?
      customer_transferable? && event.dates.uncancelled.upcoming.excluding(date).any?
    end

    def seat_customer_transferable?
      customer_transferable? && event.seating?
    end

    def signed_info(params = {})
      SigningKey.random_active.sign_ticket(self, params)
    end

    def passbook_assets_identifier
      event.assets_identifier
    end

    def passbook_file_info
      { ticket: self }
    end

    private

    def seat_required?
      event&.seating?
    end

    def customer_transferable?
      !cancelled? && (date.cancelled? || exceptionally_customer_cancellable? || date.admission_time.future?)
    end

    def seat_available
      return if seat.nil? || !seat.taken?(date)

      return unless will_save_change_to_attribute?(:seat_id) || will_save_change_to_attribute?(:date_id)

      errors.add :seat, 'seat not available'
    end

    def seat_exists_for_event
      return if seat.nil? || seating.nil? || seat.in?(seating.seats)

      errors.add :seat, 'seat does not exist for this event'
    end

    def type_exists_for_event
      return if type.nil? || event.nil? || type.in?(event.ticket_types)

      errors.add :type, 'ticket type does not exist for this event'
    end

    def valid_date
      errors.add :date, 'is cancelled' if will_save_change_to_attribute?(:date_id) && date.cancelled?
    end

    def event_ticketing_enabled
      errors.add :date, 'event ticketing is disabled' if date&.event.present? && !date&.event&.ticketing_enabled?
    end

    def update_invalidated
      self[:invalidated] = cancellation.present? || cancellation_id.present? || resale
    end

    def update_price
      self[:price] = type.price
    end
  end
end
