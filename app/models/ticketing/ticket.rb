# frozen_string_literal: true

module Ticketing
  class Ticket < ApplicationRecord
    include Cancellable

    REFUNDABLE_FOR_AFTER_DATE = 6.weeks

    belongs_to :order, touch: true
    belongs_to :type, class_name: 'TicketType'
    belongs_to :seat, optional: true
    belongs_to :date, class_name: 'EventDate'
    has_passbook_pass
    has_many :check_ins, dependent: :nullify
    has_one :covid19_attendee, validate: true, dependent: :destroy

    validates :seat, presence: { if: :seat_required? },
                     inclusion: { in: [nil], unless: :seat_required? }
    validates :order_index, uniqueness: { scope: :order_id }
    validate :seat_available, if: :seat_required?
    validate :seat_exists_for_event, if: :seat_required?
    validate :type_exists_for_event
    validates :covid19_attendee,
              presence: { if: proc { |ticket| ticket.event.covid19? } }

    before_validation :update_invalidated

    delegate :event, to: :date, allow_nil: true
    delegate :block, to: :seat, allow_nil: true

    def type=(type)
      super
      self[:price] = type.price
    end

    def number
      "#{order.number}-#{self[:order_index]}"
    end

    def resale=(value)
      return if seat.blank?

      super
    end

    def resold?
      return false if seat.blank?

      seat.taken?(date)
    end

    def refundable?
      !cancelled? && date.cancelled? &&
        (date.date + REFUNDABLE_FOR_AFTER_DATE).future?
    end

    def signed_info(params = {})
      SigningKey.random_active.sign_ticket(self, params)
    end

    def passbook_file_identifier
      event.identifier
    end

    def passbook_assets_identifier
      event.assets_identifier
    end

    def passbook_file_info
      { ticket: self }
    end

    private

    def seat_required?
      seating&.plan?
    end

    def seat_available
      return if seat.nil? || !seat.taken?(date)

      return unless will_save_change_to_attribute?(:seat_id) ||
                    will_save_change_to_attribute?(:date_id)

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

    def update_invalidated
      self[:invalidated] = cancellation.present? || cancellation_id.present? ||
                           resale
    end

    def seating
      event&.seating
    end
  end
end
