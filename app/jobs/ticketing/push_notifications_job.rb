module Ticketing
  class PushNotificationsJob < ApplicationJob
    queue_as :default

    def self.create_pool(size:, force_production: false)
      ConnectionPool.new(size: size) do
        development = Rails.env.development? && !force_production
        credentials = Rails.application.credentials.apns
        connection_options = {
          auth_method: :token,
          cert_path: StringIO.new(credentials[:key]),
          key_id: credentials[:key_id],
          team_id: Settings.apns.team_id
        }

        connection = Apnotic::Connection.send(development ? :development : :new, connection_options)
        # we must catch this exception or the whole Sidekiq process will die, not just this thread
        connection.on(:error) do |exception|
          logger.error "Exception has been raised on APNS socket: #{exception}"
        end
        connection
      end
    end

    CONNECTION_POOL = create_pool(size: 5)

    # add another production pool even if in development -> passbook notifications only support production
    CONNECTION_POOL_PRODUCTION = create_pool(size: 1, force_production: true) if Rails.env.development?

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
