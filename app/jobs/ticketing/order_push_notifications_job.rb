# frozen_string_literal: true

module Ticketing
  class OrderPushNotificationsJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(order, admin: false)
      @order = order
      @admin = admin

      subscriptions.find_each do |subscription|
        subscription.push(notification)
      end
    end

    private

    def subscriptions
      Ticketing::PushNotifications::WebSubscription.all
    end

    def notification
      {
        title:,
        body:,
        navigate:,
        silent: false,
        mutable: true,
        # TODO: remove this after grace period for service worker updates
        order_url: navigate
      }
    end

    def title
      I18n.t(
        :title,
        scope: i18n_scope,
        event: @order.event&.name
      )
    end

    def body
      I18n.t(
        body_key,
        scope: i18n_scope,
        count: @order.items.count,
        store: @order.try(:store)&.name,
        box_office: @order.try(:box_office)&.name,
        date:
      )
    end

    def navigate
      ticketing_order_url(@order)
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
