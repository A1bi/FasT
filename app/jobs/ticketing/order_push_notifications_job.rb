# frozen_string_literal: true

module Ticketing
  class OrderPushNotificationsJob < ApplicationJob
    def perform(order, admin: false)
      @order = order
      @admin = admin

      devices.find_each do |device|
        device.push(notification_data)
      end
    end

    private

    def devices
      Ticketing::PushNotifications::Device.where(app: :stats)
    end

    def notification_data
      {
        title: title,
        body: body,
        badge: badge_number,
        sound: 'cash.aif'
      }
    end

    def title
      I18n.t(
        :title,
        scope: i18n_scope,
        event: @order.event&.name,
        default: nil
      )
    end

    def body
      I18n.t(
        body_key,
        scope: i18n_scope,
        count: @order.items.count,
        store: @order.try(:store)&.name,
        box_office: @order.try(:box_office)&.name,
        date: date
      )
    end

    def badge_number
      Ticketing::Ticket.where(
        'created_at >= ?', Time.current.beginning_of_day
      ).count
    end

    def type
      return :web if @order.is_a?(Web::Order) && !@admin
      return :retail if @order.is_a? Retail::Order
      return :box_office if @order.is_a? BoxOffice::Order

      :admin
    end

    def date
      return if @order.date.blank?

      I18n.l(@order.date.date, format: '%-d. %B')
    end

    def coupons_sold?
      @order.purchased_coupons.any?
    end

    def body_key
      [:body, (type unless coupons_sold?)].join('.')
    end

    def i18n_scope
      event = coupons_sold? ? 'coupons_sold' : 'tickets_sold'
      "ticketing.push_notifications.#{event}"
    end
  end
end
