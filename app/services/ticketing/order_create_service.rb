module Ticketing
  class OrderCreateService < BaseService
    include OrderingType

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
    end

    def execute
      @order = (retail? ? Ticketing::Retail::Order : Ticketing::Web::Order).new

      if retail?
        store = Ticketing::Retail::Store.find_by(id: params[:retail_store_id])
        @order.store = store

      else
        @order.admin_validations = admin?
        @order.attributes = order_params[:address]
        create_payment
      end

      validate_event

      create_tickets
      redeem_coupons
      finalize_order

      @order
    end

    private

    def validate_event
      if date.event.sale_disabled? && !current_user&.admin?
        @order.errors.add(:event, 'Ticket sale currently disabled')
      end

      @order.errors.add(:event, 'Sold out') if date.sold_out? && !admin?
    end

    def create_tickets
      TicketCreateService.new(@order, date, current_user, params).execute
    end

    def redeem_coupons
      return unless (codes = Array(order_params[:coupon_codes])).any?

      tickets_by_price = @order.tickets.to_a.sort_by(&:price)
      free_ticket_type = date.event.ticket_types.find_by(price: 0)

      Ticketing::Coupon.where(code: codes).each do |coupon|
        next if coupon.expired?

        coupon.redeem
        @order.coupons << coupon
        next if order_params[:ignore_free_tickets].present?

        coupon.free_tickets.times do
          break if tickets_by_price.empty?

          tickets_by_price.pop.type = free_ticket_type
          coupon.free_tickets -= 1
        end
      end
    end

    def create_payment
      @order.pay_method = order_params[:payment][:method]
      return unless @order.charge_payment?

      charge_params = order_params[:payment].slice(:name, :iban)
      @order.build_bank_charge(charge_params)
    end

    def finalize_order
      ActiveRecord::Base.transaction do
        return unless @order.save

        send_push_notifications
        update_node_seats
      end
    end

    def send_push_notifications
      Ticketing::OrderPushNotificationsJob.perform_later(@order, type: type)
    end

    def update_node_seats
      return unless date.event.seating.bound_to_seats?

      NodeApi.update_seats_from_records(@order.tickets)
    end

    def order_params
      params[:order]
    end

    def date
      @date ||= Ticketing::EventDate.find(order_params[:date])
    end
  end
end
