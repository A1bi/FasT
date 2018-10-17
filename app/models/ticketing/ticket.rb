module Ticketing
  class Ticket < BaseModel
    include Cancellable

    belongs_to :order, touch: true
    belongs_to :type, class_name: 'TicketType'
    belongs_to :seat, optional: true
    belongs_to :date, class_name: 'EventDate'
    has_passbook_pass
    has_many :check_ins

    validates :seat, presence: { if: :seat_required? },
                     inclusion: { in: [nil], unless: :seat_required? }
    validate :seat_available, if: :seat_required?
    validate :seat_exists_for_event, if: :seat_required?
    validate :check_order_index, if: :order_index_changed?

    before_validation :update_invalidated
    before_save :update_passbook_pass

    def type=(type)
      super
      self[:price] = type.price
    end

    def number
      "#{order.number}-#{self[:order_index]}"
    end

    def resold?
      seat.taken?(date)
    end

    def signed_info(params = {})
      SigningKey.random_active.sign_ticket(self, params)
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
      seating&.bound_to_seats?
    end

    def seat_available
      return if seat.nil? || !seat.taken?(date)
      return unless will_save_change_to_attribute?(:seat) || will_save_change_to_attribute?(:date)
      errors.add :seat, 'seat not available'
    end

    def seat_exists_for_event
      return if seat.nil? || seating.nil? || seat.in?(seating.seats)
      errors.add :seat, 'seat does not exist for this event'
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
        passbook_pass.push
      end
    end

    def seating
      date&.event&.seating
    end
  end
end
