module Ticketing
  class Ticket < BaseModel
    include Cancellable

    belongs_to :order, touch: true
    belongs_to :type, class_name: 'TicketType'
    belongs_to :seat
    belongs_to :date, class_name: 'EventDate'
    has_passbook_pass
    has_many :check_ins

    validates_presence_of :type, :date
    validates_presence_of :seat, if: :seat_required?
    validate :check_reserved, if: :seat_required?
    validate :check_order_index, if: :order_index_changed?

    before_validation :update_invalidated
    before_save :update_passbook_pass

    def seat=(seat)
      @check_reserved = true
      super seat
    end

    def date=(date)
      @check_reserved = true
      super date
    end

    def type=(type)
      super
      self[:price] = type.price
    end

    def price
      self[:price] || 0
    end

    def number
      "#{order.number}-#{self[:order_index]}"
    end

    def resold?
      seat.taken?(date)
    end

    def can_check_in?
      !checked_in?
    end

    def checked_in?
      !!checkins.last.try(:in)
    end

    def signed_info(medium = nil)
      SigningKey.random_active.sign_ticket(self, medium)
    end

    def api_hash(details = [])
      hash = {
        id: id.to_s,
        number: number.to_s,
        date_id: date.id.to_s,
        type_id: type_id.to_s,
        price: price,
        seat_id: seat ? seat.id.to_s : nil
      }
      hash.merge!({
        picked_up: picked_up,
        resale: resale
      }) if details.include? :status
      hash.merge(super)
    end

    def create_passbook_pass
      if passbook_pass.nil?
        update_passbook_pass(true)
        save
      end
    end

    private

    def seat_required?
      date.event.seating.bound_to_seats?
    end

    def check_reserved
      if @check_reserved && seat.taken?(date)
        errors.add :seat, "seat not available"
      end
    end

    def check_order_index
      if self.class.where(order_id: order_id, order_index: order_index).any?
        errors.add :order_index, "duplicate order index"
      end
    end

    def update_invalidated
      self[:invalidated] = cancellation.present? || cancellation_id.present? || resale
    end

    def update_passbook_pass(create = false)
      if passbook_pass.present? || create
        super(date.event.identifier, { ticket: self })

        NodeApi.push_to_app(:passbook, { aps: "" }, passbook_pass.devices.map { |device| device.push_token })
      end
    end
  end
end
