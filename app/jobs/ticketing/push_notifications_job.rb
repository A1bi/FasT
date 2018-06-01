module Ticketing
  class PushNotificationsJob < ApplicationJob
    queue_as :default

    CREDENTIALS = Rails.application.credentials.apns

    CONNECTION_OPTIONS = {
      auth_method: :token,
      cert_path: StringIO.new(CREDENTIALS[:key]),
      key_id: CREDENTIALS[:key_id],
      team_id: Settings.apns.team_id
    }

    CONNECTION_POOL = Apnotic::ConnectionPool.send(Rails.env.development? ? :development : :new,
                                                   CONNECTION_OPTIONS,
                                                   size: 2)

    if Rails.env.development?
      CONNECTION_POOL_PRODUCTION = Apnotic::ConnectionPool.new(CONNECTION_OPTIONS, size: 1)
    end

    def perform(device, body: nil, title: nil, badge: nil, sound: nil, force_production_gateway: false)
      pool = Rails.env.development? && force_production_gateway ? CONNECTION_POOL_PRODUCTION : CONNECTION_POOL

      pool.with do |connection|
        notification       = Apnotic::Notification.new(device.token)
        notification.topic = device.topic
        notification.alert = {
          title: title,
          body: body
        }
        notification.badge = badge
        notification.sound = sound

        response = connection.push(notification)
        raise 'Timeout sending a push notification' unless response

        if response.status == '410' ||
          (response.status == '400' && response.body['reason'] == 'BadDeviceToken')
          device.destroy
        end
      end
    end
  end
end
