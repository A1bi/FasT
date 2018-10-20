module Ticketing
  class OrderPushNotificationsJob < ApplicationJob
    queue_as :default

    def perform(order, type:)
      scope = 'ticketing.push_notifications.tickets_sold'

      title = I18n.translate(
        :title,
        scope: scope,
        event: order.event.name
      )

      body = I18n.translate(
        type,
        scope: scope + '.body',
        count: order.tickets.count,
        store: order.try(:store)&.name,
        date: I18n.localize(order.date.date, format: '%-d. %B')
      )

      badge = Ticketing::Ticket.where('created_at >= ?', Time.zone.now.beginning_of_day).count

      Ticketing::PushNotifications::Device.where(app: :stats).find_each do |device|
        device.push(title: title, body: body, badge: badge, sound: 'cash.aif')
      end
    end
  end
end
