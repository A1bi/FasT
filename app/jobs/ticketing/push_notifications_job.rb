# frozen_string_literal: true

module Ticketing
  class PushNotificationsJob < ApplicationJob
    retry_on Errno::ETIMEDOUT

    def self.create_pool(force_production: false)
      development = Rails.env.development? && !force_production
      credentials = Rails.application.credentials.apns

      Apnotic::ConnectionPool.public_send(
        development ? :development : :new,
        {
          auth_method: :token,
          cert_path: StringIO.new(credentials[:key]),
          key_id: credentials[:key_id],
          team_id: Settings.apns.team_id
        },
        size: ENV.fetch('RAILS_MAX_THREADS', 5)
      ) do |connection|
        # we must catch this exception or the whole Sidekiq process will die,
        # not just this thread
        connection.on(:error) do |exception|
          Raven.capture_exception(exception) unless exception.is_a? SocketError
        end
      end
    end

    CONNECTION_POOL = create_pool

    # add another production pool even if in development
    # -> passbook notifications only support production
    if Rails.env.development?
      CONNECTION_POOL_PRODUCTION = create_pool(force_production: true)
    end

    def perform(device, body: nil, title: nil, badge: nil, sound: nil,
                force_production_gateway: false)
      connection_pool(force_production_gateway).with do |connection|
        notification       = Apnotic::Notification.new(device.token)
        notification.topic = device.topic
        notification.alert = {
          title: title,
          body: body
        }
        notification.badge = badge
        notification.sound = sound

        response = connection.push(notification)
        raise Errno::ETIMEDOUT unless response

        device.destroy if bad_device?(response)
      end
    end

    private

    def connection_pool(force_production_gateway)
      if Rails.env.development? && force_production_gateway
        CONNECTION_POOL_PRODUCTION
      else
        CONNECTION_POOL
      end
    end

    def bad_device?(response)
      response.status == '410' ||
        (response.status == '400' &&
         response.body['reason'] == 'BadDeviceToken')
    end
  end
end
