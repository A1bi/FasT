# frozen_string_literal: true

module Ticketing
  class OrderSimulationService < BaseService
    def initialize(params)
      super(nil, params)
    end

    def execute
      result = {}

      result[:subtotal] = tickets_sum + purchased_coupon_sum
      result[:total] = result[:subtotal] + free_tickets_discount
      result[:total_after_coupons] = [0, result[:total] - coupon_credit_sum].max
      result[:free_tickets_discount] = free_tickets_discount
      result[:credit_discount] = result[:total_after_coupons] - result[:total]

      result[:redeemed_coupons] = coupons

      unlock_exclusive_seats

      result
    end

    private

    def tickets_sum
      @ticket_prices = []

      params[:tickets].sum do |type_id, number|
        next 0 unless number.positive? &&
                      (ticket_type = event.ticket_types.find_by(id: type_id))

        @ticket_prices += [ticket_type.price] * number

        number * ticket_type.price
      end
    end

    def purchased_coupon_sum
      @purchased_coupon_sum ||= (params[:coupons] || []).sum do |coupon|
        coupon[:value] * coupon[:number]
      end
    end

    def free_tickets_discount
      @free_tickets_discount ||=
        if coupon_free_tickets_sum.zero?
          0
        else
          start = [coupon_free_tickets_sum, @ticket_prices.count].min
          -@ticket_prices.sort[-start..].sum
        end
    end

    def coupons
      @coupons ||= Coupon.valid.with_codes(params[:coupon_codes])
    end

    def coupon_free_tickets_sum
      @coupon_free_tickets_sum ||= coupons.free_tickets_value.balance_sum
    end

    def coupon_credit_sum
      @coupon_credit_sum ||= coupons.credit_value.balance_sum
    end

    def event
      @event ||= Event.find(params[:event_id])
    end

    def unlock_exclusive_seats
      return unless event.seating? && params[:socket_id] && coupon_free_tickets_sum.positive?

      NodeApi.seating_request('setExclusiveSeats',
                              { seats: exclusive_seats }, params[:socket_id])
    end

    def exclusive_seats
      return if (group = ReservationGroup.find_by(name: 'Sponsoren')).blank?

      group.reservations.where(date: event.dates)
           .each_with_object({}) do |reservation, seats|
             (seats[reservation.date_id] ||= []) << reservation.seat_id
      end
    end
  end
end
