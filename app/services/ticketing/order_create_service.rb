module Ticketing
  class OrderCreateService < BaseService
    class FreeTicketTypeMissingError < StandardError; end

    include OrderingType

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
    end

    def execute
      @order = order_class.new

      if retail?
        store = Ticketing::Retail::Store.find_by(id: params[:retail_store_id])
        @order.store = store

      elsif box_office?
        box_office = Ticketing::BoxOffice::BoxOffice
                     .find_by(id: params[:box_office_id])
        @order.box_office = box_office

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
      raise FreeTicketTypeMissingError if free_ticket_type.nil?

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

        update_node_seats
      end

      suppress_in_production(StandardError) do
        send_push_notifications
      end
    end

    def send_push_notifications
      Ticketing::OrderPushNotificationsJob.perform_later(@order, admin: admin?)
    end

    def update_node_seats
      return unless date.event.seating.bound_to_seats?

      NodeApi.update_seats_from_records(@order.tickets)
    end

    def order_class
      if retail?
        Ticketing::Retail::Order
      elsif box_office?
        Ticketing::BoxOffice::Order
      else
        Ticketing::Web::Order
      end
    end

    def order_params
      params[:order]
    end

    def date
      @date ||= Ticketing::EventDate.find(order_params[:date])
    end
  end
end
