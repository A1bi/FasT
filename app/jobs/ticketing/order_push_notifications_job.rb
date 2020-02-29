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
      I18n.translate(
        :title,
        scope: i18n_scope,
        event: @order.event.name
      )
    end

    def body
      I18n.translate(
        type,
        scope: i18n_scope + '.body',
        count: @order.tickets.count,
        store: @order.try(:store)&.name,
        box_office: @order.try(:box_office)&.name,
        date: I18n.localize(@order.date.date, format: '%-d. %B')
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

    def i18n_scope
      'ticketing.push_notifications.tickets_sold'
    end
  end
end
